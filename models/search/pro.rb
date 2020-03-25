# frozen_string_literal: true

class Search::Pro < Search::Base
  ATTRIBUTES = %i[
    area_ids
    available_time_ids
    condition_text
    current_user
    industry_category_id
    is_acceptable
    is_fb_friend
    is_remote
    new_arrival
    profession_category_id
    profession_ids
    scout_list_title
    skill_names
    sort
  ].freeze

  class SortType < ActiveHash::Base
    include ActiveHash::Enum
    self.data = [
      { id: 1, type: 'new', name: '新着順' },
      { id: 2, type: 'login', name: 'ログイン順' }
    ]
    enum_accessor :type
  end

  attr_accessor(*ATTRIBUTES)

  def initialize(pros, attr = {})
    super(attr) if attr.present?
    self.skill_names = cleansing_skill_names if skill_names.present?
    self.sort ||= SortType::NEW.id
    @pros = initialize_pros(pros)
  end

  def matches
    pros = @pros.order(id: :desc)
    pros = pros.joins(:pro_info).merge(ProInfo.where(is_public: true)) if searching?
    pros = pros.joins(:pro_info).merge(ProInfo.where(available_time_id: available_time_ids)) if available_time_ids.present?
    pros = pros.joins(:pro_info).merge(ProInfo.where(is_remote: true)) if is_remote.present?
    pros = pros.joins(:pro_info).merge(ProInfo.where.not(acceptable_status_id: AcceptableStatus::BUSY.id)) if is_acceptable.present?
    pros = search_by_fb_friend(pros) if is_fb_friend.present?
    pros = search_by_area(pros) if area_ids.present?
    pros = search_by_industry(pros) if industry_category_id.present?
    pros = search_by_skill_names(pros) if skill_names.present?
    pros = search_by_profession(pros) if profession_category_id.present?
    pros.distinct
  end

  # NOTE: #141にて実装
  # 非公開プロ人材も一覧に載せるが、スカウトリスト作成時にはスカウト対象から外すため、「検索が実行された際には非公開はださない」ようにしている
  def searching?
    search_list = %i[area_ids available_time_ids industry_category_id is_acceptable is_fb_friend is_remote profession_category_id skill_names]
    search_list.any? { |sl| send(sl).present? }
  end

  private

  def initialize_pros(pros)
    case sort.to_i
    when SortType::LOGIN.id
      pros.order(current_sign_in_at: :desc)
    when SortType::NEW.id
      # 本来はcreated_atのDESCだけど、IDのDESCで十分なので
      pros
    else
      pros.none
    end
  end

  def cleansing_skill_names
    # 分割は句読点かコンマ。
    # スカウトリストの検索条件に載せる都合上、句読点にした方が都合がいいため「、」をjoin
    self.skill_names = skill_names.split(/,|、/).map(&:strip).reject(&:blank?).join('、')
  end

  def search_by_area(pros)
    pref_ids = Array(Area.find(area_ids)).map(&:prefectures).flatten.pluck(:id)
    pros.where(prefecture_id: pref_ids)
  end

  def search_by_fb_friend(pros)
    friend_ids = GetFriendsQuery.new(current_user).call.ids
    pros.where(id: friend_ids)
  end

  def search_by_industry(pros)
    industry_ids = IndustryCategory.find(industry_category_id).industries.ids
    pros.joins(pro_info: :industries).merge(Industry.where(id: industry_ids))
  end

  def search_by_profession(pros)
    pros = pros.joins(pro_info: :professions)
    if profession_ids.blank?
      return pros.merge(Profession.where(id: ProfessionCategory.find(profession_category_id).professions.map(&:id)))
    end

    pro_ids = pros.merge(Profession.where(id: profession_ids[0]))
    profession_ids[1..].each do |profession_id|
      pro_ids &= pros.merge(Profession.where(id: profession_id))
    end
    pros.where(id: pro_ids)
  end

  def search_by_skill_names(pros)
    pros = pros.joins(pro_info: :skills)
    skill_name_list = skill_names.split('、')
    return pros if skill_name_list.empty?

    pro_ids = pros.where('skills.title ILIKE ?', "%#{skill_name_list[0]}%").ids
    skill_name_list[1..].each do |skill_name|
      pro_ids &= pros.where('skills.title ILIKE ?', "%#{skill_name}%").ids
    end
    pros.where(id: pro_ids)
  end
end

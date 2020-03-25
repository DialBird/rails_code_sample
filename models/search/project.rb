# frozen_string_literal: true

# NOTE: 返り値のclassがArrayであることに注意
# 「おすすめ順」を実装するために、ActiveRecordのままでは実現が難しい為
class Search::Project < Search::Base
  ATTRIBUTES = %i[
    area_ids
    available_time_ids
    current_user
    current_user_profession_ids
    is_closed
    new_arrival
    profession_category_id
    profession_ids
    public_only
    remote_types
    skill_name
    sort
  ].freeze

  class SortType < ActiveHash::Base
    include ActiveHash::Enum
    self.data = [
      { id: 1, type: 'new', name: '新着順', usable_when_logout: true },
      { id: 2, type: 'recommend', name: 'おすすめ順', usable_when_logout: false },
      { id: 3, type: 'max_wage', name: '上限金額が高い順', usable_when_logout: true }
    ]
    enum_accessor :type
  end

  attr_accessor(*ATTRIBUTES)

  def initialize(projects, attr = {})
    super(attr) if attr.present?
    self.skill_name = skill_name.strip if skill_name.present?
    self.sort ||= SortType::NEW.id
    self.current_user_profession_ids ||= current_user&.can_accept? ? current_user.professions.ids : []
    @projects = projects
  end

  def matches
    projects = @projects
    projects = search_by_area(projects) if area_ids.present?
    projects = projects.where(available_time_id: available_time_ids) if available_time_ids.present?
    projects = search_by_profession(projects) if profession_category_id.present?
    projects = projects.where(is_private: false) if public_only.present?
    projects = projects.where(remote_type: remote_types) if remote_types.present?
    projects = projects.where(state: %w[opened]) if is_closed.present?
    projects = search_by_skill_name(projects) if skill_name.present?
    projects = projects.distinct
    # NOTE: ここでクラスが配列に変わる
    sort_with_condition(projects)
  end

  private

  def search_by_area(projects)
    pref_ids = Array(Area.find(area_ids)).map(&:prefectures).flatten.pluck(:id)
    # NOTE: 都道府県が「全国」の案件は全てのエリアで検出させる
    pref_ids.append(Prefecture.find_by(name: '全国').id)
    projects.where(prefecture_id: pref_ids)
  end

  def search_by_profession(projects)
    projects.joins(:project_professions).merge(ProjectProfession.where(profession_id: profession_ids))
  end

  def search_by_skill_name(projects)
    projects.joins(:required_skills).where('required_skills.title ILIKE ?', "%#{skill_name}%")
  end

  # NOTE: 全てに共通で、募集終了案件は末尾に新着順で付与すること（#557）
  def sort_with_condition(projects)
    # 募集終了案件を抽出
    closed_projects = projects.closed.order(application_open_at: :desc, id: :desc).to_a
    projects = projects.where.not(id: closed_projects.map(&:id))

    # 募集中案件をソート
    opened_projects = case sort.to_i
                      when SortType::NEW.id
                        projects.order(application_open_at: :desc, id: :desc).to_a
                      when SortType::RECOMMEND.id
                        # NOTE: 職種による検索を上書きしないように、新しく「ログインユーザー向けの案件」を絞り込み、
                        # その案件IDでwhereを貼るようにする
                        project_ids_for_current_user =
                          Project.all
                          .joins(:project_professions)
                          .merge(ProjectProfession.where(profession_id: current_user_profession_ids))
                          .distinct
                          .ids
                        p1 = projects.where(id: project_ids_for_current_user).order(application_open_at: :desc)
                        p2 = projects.where.not(id: project_ids_for_current_user).order(application_open_at: :desc)
                        p1.to_a + p2.to_a
                      when SortType::MAX_WAGE.id
                        projects.order(max_budget_id: :desc, id: :desc).to_a
                      end
    opened_projects + closed_projects
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: projects # 案件
#
#  id                                       :bigint(8)        not null, primary key
#  applicants_count                         :integer          default(0), not null
#  application_close_at                     :date
#  application_open_at                      :datetime
#  detail                                   :text
#  is_corp_name_secret                      :boolean          default(FALSE), not null
#  is_new_like                              :boolean          default(FALSE), not null
#  is_owner_name_and_common_relation_secret :boolean          default(FALSE), not null
#  is_private                               :boolean          default(FALSE), not null
#  is_remotable                             :boolean          default(TRUE), not null
#  is_template                              :boolean          default(FALSE), not null
#  notified_pro_count                       :integer          default(0), not null
#  ogp_image                                :string
#  receive_likes_count                      :integer          default(0), not null
#  remote_type                              :integer          default("full_remote"), not null
#  state                                    :integer
#  title                                    :string           default(""), not null
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  available_time_id                        :integer
#  corporation_id                           :bigint(8)
#  created_by_id                            :bigint(8)
#  max_budget_id                            :integer
#  min_budget_id                            :integer
#  prefecture_id                            :integer
#
# Indexes
#
#  index_projects_on_corporation_id  (corporation_id)
#  index_projects_on_created_by_id   (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (created_by_id => users.id)
#

class Project < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include AASM
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks if Rails.env.test?
  include Postscriptable

  class DisplayOwnerInfoType < ActiveHash::Base
    include ActiveHash::Enum
    self.data = [
      { type: :all, name: '全て表示' },
      { type: :only_corp_name, name: '会社名のみ表示' },
      { type: :not_show, name: '全て表示しない' }
    ]
    enum_accessor :type
  end

  ATTRIBUTES = %i[
    id
    application_close_at
    available_time_id
    corporation_id
    detail
    display_owner_info_type
    is_corp_name_secret
    is_owner_name_and_common_relation_secret
    is_private
    is_template
    max_budget_id
    min_budget_id
    prefecture_id
    remote_type
    title
  ].freeze

  attr_writer :display_owner_info_type

  enum remote_type: {
    full_remote: 1,
    part_remote: 2,
    no_remote: 3
  }

  # NOTE: 2に該当するステータスがもともとあったが、無くなった
  # closedを2に変えても良かったが、面倒くさいので放置している
  enum state: {
    draft: 0,
    opened: 1,
    closed: 3
  }

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :opened
    state :closed

    event :open do
      transitions from: :draft, to: :opened, after: -> { update(application_open_at: Time.current) }
    end
    event :close do
      transitions from: :opened, to: :closed, after: -> { update(application_close_at: Time.current) }
    end
  end

  belongs_to_active_hash :prefecture
  belongs_to_active_hash :available_time
  belongs_to_active_hash :min_budget, class_name: 'Budget'
  belongs_to_active_hash :max_budget, class_name: 'Budget'

  mount_uploader :ogp_image, ProjectOgpImageUploader

  settings index: {
    number_of_shards: 2,
    number_of_replicas: 1,
    analysis: {
      filter: {
        pos_filter: {
          type: 'kuromoji_part_of_speech',
          stoptags: ['助詞-格助詞-一般', '助詞-終助詞']
        },
        lowercase_filter: {
          type: 'lowercase',
          language: 'greek'
        }
      },
      tokenizer: {
        kuromoji_tokenizer: {
          type: 'kuromoji_tokenizer',
          mode: 'search'
        }
      },
      analyzer: {
        kuromoji_analyzer: {
          type: 'custom',
          tokenizer: 'kuromoji_tokenizer',
          char_filter: [
            'html_strip',
            'icu_normalizer'
          ],
          filter: [
            'icu_normalizer',
            'ja_stop',
            'kuromoji_baseform',
            'kuromoji_number',
            'kuromoji_stemmer',
            'lowercase_filter',
            'pos_filter'
          ]
        }
      }
    }
  } do
    mapping dynamic: false do
      indexes :id, type: :integer, index: false
      indexes :title, type: :text, analyzer: :kuromoji_analyzer
      indexes :detail, type: :text, analyzer: :kuromoji_analyzer
    end
  end

  belongs_to :corporation
  # NOTE: created_byには、下書き作成・更新か、募集開始の実行者が入る。
  # 「上の処理のいずれかを最後に実行した人」で更新され続けることに注意
  belongs_to :created_by, class_name: 'User'
  has_one :project_scout_list, dependent: :destroy
  has_many :pro_project_relations, dependent: :destroy
  has_many :project_likes, dependent: :destroy
  has_many :project_notified_pros, dependent: :destroy
  has_many :project_professions, dependent: :destroy
  has_many :required_skills, dependent: :destroy, inverse_of: :project

  has_one :scout_list, through: :project_scout_list
  has_many :project_chat_rooms, through: :pro_project_relations, source: :project_chat_room
  has_many :pros, through: :pro_project_relations

  delegate :more_than_light_plan?, to: :corporation, prefix: true

  accepts_nested_attributes_for :project_professions, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :project_scout_list, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :required_skills, allow_destroy: true, reject_if: :all_blank

  before_validation :reflect_display_owner_info_type

  validates :title, presence: true, length: { maximum: 35 }
  with_options unless: -> { validation_context == :draft } do
    validates :available_time_id, inclusion: { in: AvailableTime.for_project.map(&:id) }
    validates :detail, presence: true
    validates :prefecture_id, inclusion: { in: Prefecture.for_project.map(&:id) }
    validates :project_professions, length: { minimum: 1, maximum: 3 }
    validate :budget_should_set_appropriately
    validate :professions_should_be_uniq
  end

  def corporation_worker?(user)
    return false unless corporation

    corporation.worker?(user)
  end

  def display_owner_info_type
    @display_owner_info_type || if is_corp_name_secret && is_owner_name_and_common_relation_secret
                                  DisplayOwnerInfoType::NOT_SHOW.name
                                elsif is_owner_name_and_common_relation_secret
                                  DisplayOwnerInfoType::ONLY_CORP_NAME.name
                                else
                                  DisplayOwnerInfoType::ALL.name
                                end
  end

  def reflect_display_owner_info_type
    case display_owner_info_type
    when DisplayOwnerInfoType::ALL.name
      self.is_corp_name_secret = false
      self.is_owner_name_and_common_relation_secret = false
    when DisplayOwnerInfoType::ONLY_CORP_NAME.name
      self.is_corp_name_secret = false
      self.is_owner_name_and_common_relation_secret = true
    when DisplayOwnerInfoType::NOT_SHOW.name
      self.is_corp_name_secret = true
      self.is_owner_name_and_common_relation_secret = true
    end
  end

  private

  def budget_should_set_appropriately
    if min_budget_id.zero? || max_budget_id.zero?
      errors.add(:base, I18n.t('errors.messages.budget_blank'))
    elsif max_budget_id <= min_budget_id
      errors.add(:base, I18n.t('errors.messages.budget_not_set_appropriately'))
    end
  end

  def professions_should_be_uniq
    return if project_professions.size == project_professions.map(&:profession_id).uniq.size

    errors.add(:base, '職種が重複しています')
  end
end

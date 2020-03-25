# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint(8)        not null, primary key
#  birth_year                 :integer          default(0), not null    # 誕生年
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  cover_image                :string                                   # カバー写真
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  deregistered_at            :datetime
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null   # 名
#  first_name_kana            :string           default(""), not null   # 名（フリガナ）
#  is_apply_notice_on         :boolean          default(TRUE), not null
#  is_message_notice_on       :boolean          default(TRUE), not null
#  is_new_pro_notice_on       :boolean          default(TRUE), not null
#  is_news_notice_on          :boolean          default(TRUE), not null
#  is_project_liked_notice_on :boolean          default(TRUE), not null
#  last_name                  :string           default(""), not null   # 姓
#  last_name_kana             :string           default(""), not null   # 姓（フリガナ）
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  profile_image              :string                                   # プロファイル写真
#  receive_likes_count        :integer          default(0), not null    # いいねのカウントカラム
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#  state                      :string           default(""), not null   # ステータス
#  unconfirmed_email          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  current_corporation_id     :bigint(8)
#  prefecture_id              :integer          default(0), not null    # 都道府県（prefecture.yml参照）
#  usage_type_id              :integer          default(0), not null    # 主な用途（usage_type.yml参照）
#
# Indexes
#
#  index_users_on_confirmation_token      (confirmation_token) UNIQUE
#  index_users_on_current_corporation_id  (current_corporation_id)
#  index_users_on_current_sign_in_at      (current_sign_in_at)
#  index_users_on_email                   (email) UNIQUE
#  index_users_on_reset_password_token    (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (current_corporation_id => corporations.id)
#

class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  include AASM

  class UsageType < ActiveHash::Base
    include ActiveHash::Enum
    self.data = [{ id: 1, type: :accepting, name: '受注' }, { id: 2, type: :ordering, name: '発注' }]
    enum_accessor :type
  end

  COMMON_ATTRIBUTES = %i[
    birth_year
    first_name
    first_name_kana
    last_name
    last_name_kana
    prefecture_id
    usage_type_id
  ].freeze
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/.freeze

  attr_accessor :current_password

  aasm column: 'state' do
    state :common_settings_required, initial: true
    state :accept_settings_required
    state :skill_settings_required
    state :slogan_settings_required
    state :order_settings_required
    state :settings_completed
    # NOTE: 招待用フロー
    state :invited_settings_required

    event :to_accept_settings do
      transitions from: :common_settings_required, to: :accept_settings_required
    end
    event :to_skill_settings do
      transitions from: :accept_settings_required, to: :skill_settings_required
    end
    event :to_slogan_settings do
      transitions from: :skill_settings_required, to: :slogan_settings_required
    end
    event :to_order_settings do
      transitions from: :common_settings_required, to: :order_settings_required
    end
    event :complete_settings do
      transitions from: %i[slogan_settings_required order_settings_required invited_settings_required], to: :settings_completed
    end
  end

  belongs_to_active_hash :prefecture

  mount_uploader :profile_image, ProfileImageUploader
  mount_uploader :cover_image, CoverImageUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :omniauthable,
         omniauth_providers: %i[facebook google]

  belongs_to :current_corporation, optional: true, class_name: 'Corporation'
  has_one :pro_info, dependent: :destroy, inverse_of: :user
  has_many :advises, -> { order(created_at: :asc) }, dependent: :destroy, inverse_of: :user
  has_many :notifications, dependent: :destroy, inverse_of: :user
  has_many :pro_project_relations, dependent: :destroy, inverse_of: :pro, foreign_key: :pro_id
  has_many :reviews, -> { order(created_at: :asc) }, dependent: :destroy, inverse_of: :reviewed, foreign_key: :reviewed_id
  has_many :scout_lists, -> { order(created_at: :desc) },  dependent: :destroy, inverse_of: :user
  has_many :send_reviews, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :reviewer, foreign_key: :reviewer_id, class_name: 'Review'
  has_many :social_profiles, dependent: :destroy, inverse_of: :user

  has_many :corporation_users, dependent: :destroy
  private :corporation_users, :corporation_users=
  has_many :project_likes, dependent: :destroy, inverse_of: :pro, foreign_key: :pro_id
  private :project_likes, :project_likes=
  has_many :project_notified_pros, dependent: :destroy, inverse_of: :pro, foreign_key: :pro_id
  private :project_notified_pros, :project_notified_pros=
  has_many :former_user_relations, dependent: :destroy, inverse_of: :former, foreign_key: :former_id, class_name: 'UserRelation'
  private :former_user_relations, :former_user_relations=
  has_many :latter_user_relations, dependent: :destroy, inverse_of: :latter, foreign_key: :latter_id, class_name: 'UserRelation'
  private :latter_user_relations, :latter_user_relations=

  has_many :corporations, through: :corporation_users
  has_many :pro_projects, through: :pro_project_relations, source: :project

  delegate :industries, :professions, :skills, to: :pro_info, allow_nil: true

  accepts_nested_attributes_for :advises, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pro_info, allow_destroy: true, update_only: true

  validates :state, inclusion: { in: User.aasm.states.map { |s| s.name.to_s } }
  validate :birth_year_should_be_past
  validate :current_corporation_id_should_be_valid
  validate :password_complexity

  # 受注・発注共通入力項目
  with_options on: :update, unless: :encrypted_password_changed? do |user|
    user.validates :last_name,  presence: true
    user.validates :first_name, presence: true
    user.validates :prefecture_id, inclusion: { in: Prefecture.for_user.map(&:id) }
    user.validates :usage_type_id, inclusion: { in: UsageType.all.map(&:id) }
  end

  class << self
    def build_from_invitation(email)
      new do |u|
        u.email = email
        u.password = ideal_password
        u.confirmed_at = Time.now.utc
        u.usage_type_id = UsageType::ORDERING.id
        u.state = 'invited_settings_required'
      end
    end

    def from_omniauth(auth, usage_type_id = nil)
      create do |u|
        u.email = auth.info.email || temp_email(auth)
        u.password = ideal_password
        u.last_name = auth.info.last_name || ''
        u.first_name = auth.info.first_name || ''
        u.remote_profile_image_url = auth.info.image || ''
        u.confirmed_at = Time.now.utc
        u.usage_type_id = usage_type_id if usage_type_id.present?
      end
    end

    private

    def ideal_password
      password = ''
      loop do
        password = Devise.friendly_token[0, 20]
        break if password =~ Settings.format.password
      end
      password
    end

    def temp_email(auth)
      "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com"
    end
  end

  # HACK: Deviseのメソッド
  # 退会した人は強制ログアウト & ログインさせない
  def active_for_authentication?
    super && active?
  end

  def active?
    deregistered_at.blank?
  end

  def admin?
    admin_email_list = [Settings.email.support].freeze
    admin_email_list.include?(email)
  end

  def email_verified?
    email && email !~ TEMP_EMAIL_REGEX
  end

  def can_accept?
    pro_info && pro_info.persisted?
  end

  def can_order?
    current_corporation.present?
  end

  def can_scout?
    can_order? && !scout_lists.empty?
  end

  def fb_user?
    social_profile(:facebook).present?
  end

  def full_name
    "#{last_name} #{first_name}"
  end

  # HACK: Deviseでログイン状態を維持し続けるために必要
  def remember_me
    true
  end

  def reset_confirmation!
    update(confirmed_at: nil)
  end

  def social_profile(provider)
    social_profiles.find_by(provider: Settings.provider.send(provider))
  end

  def usage_type_accepting?
    usage_type_id == UsageType::ACCEPTING.id
  end

  def usage_type_ordering?
    usage_type_id == UsageType::ORDERING.id
  end

  private

  def birth_year_should_be_past
    return if birth_year.zero? || birth_year < Date.today.year

    errors.add(:birth_year, I18n.t('errors.messages.birth_year_should_be_past'))
  end

  # NOTE: optionalなのでnilは許容
  # nilではない場合にはメンバーとなっている会社アカウントのIDだけ許容する
  def current_corporation_id_should_be_valid
    return if current_corporation_id.nil? || corporations.map(&:id).include?(current_corporation_id)

    errors.add(:current_corporation_id, '無効な会社アカウントです')
  end

  def password_complexity
    return if password.blank? || password =~ Settings.format.password

    errors.add(:password, I18n.t('errors.messages.invalid_format_password'))
  end
end

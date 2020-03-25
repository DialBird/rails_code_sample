# frozen_string_literal: true

# == Schema Information
#
# Table name: corporations
#
#  id                :bigint(8)        not null, primary key
#  address           :string
#  corporation_image :string
#  cover_image       :string
#  department        :string           default(""), not null
#  detail            :text
#  established_at    :date
#  facebook_url      :string
#  instagram_url     :string
#  is_freelance      :boolean          default(FALSE), not null
#  is_no_department  :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  number_of_workers :integer
#  phone             :string           default(""), not null
#  state             :string           default(""), not null
#  twitter_url       :string
#  url               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :bigint(8)
#
# Indexes
#
#  index_corporations_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#

class Corporation < ApplicationRecord
  include AASM

  ATTRIBUTES = %i[
    address
    department
    detail
    established_at
    facebook_url
    industry_id
    instagram_url
    is_freelance
    is_no_department
    name
    number_of_workers
    phone
    twitter_url
    url
  ].freeze

  aasm column: :state do
    state :personal, initial: true
    state :invitable

    event :enable_invitation do
      transitions from: :personal, to: :invitable
    end
  end

  mount_uploader :corporation_image, CorporationImageUploader
  mount_uploader :cover_image, CorporationCoverImageUploader

  belongs_to :created_by, class_name: 'User'
  has_one :corporation_industry, dependent: :destroy, inverse_of: :corporation
  has_one :message_template, dependent: :destroy, inverse_of: :corporation
  has_one :plan, dependent: :destroy, inverse_of: :corporation
  has_many :browse_pro_licenses, dependent: :destroy, inverse_of: :corporation
  has_many :corporation_sites, dependent: :destroy, inverse_of: :corporation
  has_many :projects, dependent: :destroy, inverse_of: :corporation
  has_many :recruiting_professions, dependent: :destroy, inverse_of: :corporation
  # Only for CASCADE
  has_many :corporation_users, dependent: :destroy, inverse_of: :corporation
  private :corporation_users, :corporation_users=
  has_many :invited_users, dependent: :destroy, inverse_of: :corporation
  private :invited_users, :invited_users=
  has_many :pro_likes, dependent: :destroy, inverse_of: :corporation
  private :pro_likes, :pro_likes=

  delegate :free?, :light?, :standard?, to: :plan, allow_nil: true, prefix: true

  has_many :workers, through: :corporation_users, source: :user

  accepts_nested_attributes_for :corporation_industry, update_only: true
  accepts_nested_attributes_for :corporation_sites, allow_destroy: true, reject_if: :reject_corporation_sites
  accepts_nested_attributes_for :recruiting_professions, allow_destroy: true, reject_if: :all_blank

  before_validation :add_url_protocol
  before_validation :clear_department_if_no_department
  before_validation :clear_name_if_freelance

  validates :department, length: { maximum: 30 }
  validates :department, presence: true, unless: :is_no_department?
  validates :detail, length: { maximum: 1000 }
  validates :name, length: { maximum: 140 }
  validates :name, presence: true, unless: :is_freelance?
  validates :phone, presence: true, format: { with: Settings.format.phone }

  def admin_worker?(user)
    admin_workers.include?(user)
  end

  def admin_workers
    User.where(id: corporation_users.admin.map(&:user_id))
  end

  def more_than_free_plan?
    plan.present?
  end

  def more_than_light_plan?
    plan_light? || plan_standard?
  end

  def name
    self[:is_freelance] ? 'フリーランス' : self[:name]
  end

  def worker?(user)
    workers.include?(user)
  end

  private

  def add_url_protocol
    return if url.blank? || url.start_with?('http://') || url.start_with?('https://')

    self.url = "http://#{url}"
  end

  def clear_department_if_no_department
    self.department = '' if is_no_department
  end

  def clear_name_if_freelance
    self.name = '' if is_freelance
  end

  def reject_corporation_sites(attributes)
    attributes['url'].blank? || attributes['category'].blank?
  end
end

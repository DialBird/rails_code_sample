# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_infos
#
#  id                                  :bigint(8)        not null, primary key
#  bio                                 :text             default(""), not null
#  carrier_url                         :string           default(""), not null    # 経歴がわかるリンク
#  corporation_name                    :string           default(""), not null
#  facebook_url                        :string           default(""), not null
#  github_url                          :string           default(""), not null
#  is_freelance                        :boolean          default(FALSE), not null
#  is_liked_notice_on                  :boolean          default(TRUE), not null
#  is_new_project_notice_on            :boolean          default(TRUE), not null
#  is_public                           :boolean          default(TRUE), not null
#  is_remote                           :boolean          default(FALSE), not null
#  is_scout_notice_on                  :boolean          default(TRUE), not null
#  is_thanks_for_application_notice_on :boolean          default(TRUE), not null  # 応募ありがとうメール通知スイッチ
#  is_weekly_projects_notification_on  :boolean          default(TRUE), not null
#  portfolio_attachment                :string
#  slogan                              :string           default(""), not null
#  twitter_url                         :string           default(""), not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  acceptable_status_id                :integer          default(0), not null
#  asking_wage_id                      :integer          default(0), not null
#  available_time_id                   :integer          default(0), not null
#  user_id                             :bigint(8)
#
# Indexes
#
#  index_pro_infos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class ProInfo < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  class AskingWage < ActiveHash::Base
    wages = [
      1000, 2000, 2500, 3000, 3500, 4000, 4500, 5000,
      6000, 7000, 8000, 9000, 10000, 15000, 20000,
      25000, 30000, 35000, 40000, 45000, 50000
    ].map { |wage| "#{wage}円/時間" }
    list = [{ id: 0, name: '依頼人と相談して決める' }]
    wages.each.with_index(1) do |wage, idx|
      list << { id: idx, name: wage }
    end
    list << { id: list.size, name: '50000円/時間〜' }
    self.data = list
  end

  ATTRIBUTES = %i[
    acceptable_status_id
    asking_wage_id
    available_time_id
    bio
    carrier_url
    corporation_name
    facebook_url
    github_url
    is_freelance
    is_public
    is_remote
    portfolio_attachment
    slogan
    twitter_url
  ].freeze

  belongs_to_active_hash :acceptable_status
  belongs_to_active_hash :asking_wage, class_name: 'ProInfo::AskingWage'
  belongs_to_active_hash :available_time

  mount_uploader :portfolio_attachment, AttachmentUploader

  belongs_to :user
  has_many :carriers, dependent: :destroy, inverse_of: :pro_info
  has_many :pro_industries, dependent: :destroy, inverse_of: :pro_info
  has_many :pro_professions, dependent: :destroy, inverse_of: :pro_info
  has_many :sites, dependent: :destroy, inverse_of: :pro_info
  has_many :skills, dependent: :destroy, inverse_of: :pro_info

  has_many :industries, through: :pro_industries
  has_many :professions, through: :pro_professions

  accepts_nested_attributes_for :carriers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pro_industries, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :pro_professions, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :sites, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :skills, allow_destroy: true, reject_if: :all_blank

  before_validation :clear_corporation_name_if_freelance

  validates :acceptable_status_id, inclusion: { in: AcceptableStatus.all.map(&:id).append(0) }
  validates :asking_wage_id, inclusion: { in: AskingWage.all.map(&:id) }
  validates :available_time_id, inclusion: { in: AvailableTime.for_pro.map(&:id).append(0) }
  validates :bio, length: { maximum: 1000 }
  validates :corporation_name, length: { maximum: 140 }
  # NOTE: フリーランスじゃない場合のみ「会社名」が必須
  validates :corporation_name, presence: true, unless: :is_freelance?
  validates :sites, length: { maximum: 5 }
  validates :slogan, length: { maximum: 40 }

  scope :opened, -> { where(is_public: true) }

  def corporation_name
    self[:is_freelance] ? 'フリーランス' : self[:corporation_name]
  end

  private

  def clear_corporation_name_if_freelance
    self.corporation_name = '' if is_freelance
  end
end

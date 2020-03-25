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

# NOTE: 使うときは必ずproかordererから呼び出す
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password1' }
    last_name { '山田' }
    sequence(:first_name) { |n| "#{n}太郎" }
    prefecture_id { Prefecture.first.id }
    confirmed_at { Time.now.utc }
    current_sign_in_at { Time.current }

    trait :facebook do
      transient do
        uid { '12345' }
      end
      after :build do |user, evaluator|
        user.social_profiles << build(:social_profile, :facebook, user: user, uid: evaluator.uid)
      end
    end
    trait :inactive do
      deregistered_at { Time.current }
    end

    factory :pro do
      usage_type_id { User::UsageType::ACCEPTING.id }
      state { 'settings_completed' }
      transient do
        acceptable_status_id { AcceptableStatus.first.id }
        available_time_id { AvailableTime.first.id }
        industry_id { Industry.first.id }
        is_public { true }
        is_remote { true }
        profession_id { Profession.first.id }
        skill_title { 'スキル名' }
      end
      after :build do |user, evaluator|
        user.pro_info ||=
          build(:pro_info,
                acceptable_status_id: evaluator.acceptable_status_id,
                available_time_id: evaluator.available_time_id,
                industry_id: evaluator.industry_id,
                is_public: evaluator.is_public,
                is_remote: evaluator.is_remote,
                profession_id: evaluator.profession_id,
                skill_title: evaluator.skill_title)
      end
    end
    factory :orderer do
      usage_type_id { User::UsageType::ORDERING.id }
      state { 'settings_completed' }
      transient do
        corporation { nil }
      end
      after :create do |user, evaluator|
        corporation = evaluator.corporation || create(:corporation, created_by: user)
        create(:corporation_user, corporation: corporation, user: user)
        user.update(current_corporation_id: corporation.id)
      end
    end
  end
end

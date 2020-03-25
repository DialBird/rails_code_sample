# frozen_string_literal: true

# == Schema Information
#
# Table name: social_profiles # SNSアカウント
#
#  id         :bigint(8)        not null, primary key
#  provider   :string           default(""), not null # プロバイダ名
#  uid        :string           default(""), not null # プロバイダ固有ID
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          default(0), not null  # ユーザーID
#
# Indexes
#
#  by_uid  (uid,provider) UNIQUE
#
# Foreign Keys
#
#  social_profiles_user_id_fk  (user_id => users.id)
#

FactoryBot.define do
  factory :social_profile do
    association :user, factory: :pro
    sequence(:uid) { |n| (10000 + n).to_s }
    provider { Settings.provider.facebook }

    trait :facebook do
      provider { Settings.provider.facebook }
    end
    trait :google do
      provider { Settings.provider.google }
    end
  end
end

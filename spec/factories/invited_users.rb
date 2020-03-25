# frozen_string_literal: true

# == Schema Information
#
# Table name: invited_users
#
#  id               :bigint(8)        not null, primary key
#  email            :string           default(""), not null
#  invitation_token :string           default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corporation_id   :bigint(8)
#
# Indexes
#
#  index_invited_users_on_corporation_id    (corporation_id)
#  index_invited_users_on_email             (email) UNIQUE
#  index_invited_users_on_invitation_token  (invitation_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#

FactoryBot.define do
  factory :invited_user do
    sequence(:email) { |n| "invited#{n}@co.jp" }
    association :corporation
  end
end

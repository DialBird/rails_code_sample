# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id             :bigint(8)        not null, primary key
#  rank           :integer          default(NULL), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#
# Indexes
#
#  index_plans_on_corporation_id  (corporation_id)
#

FactoryBot.define do
  factory :plan do
    association :corporation
    rank { 'free' }
  end
end

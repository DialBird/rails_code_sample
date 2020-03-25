# frozen_string_literal: true

# == Schema Information
#
# Table name: bounce_emails
#
#  id         :bigint(8)        not null, primary key
#  email      :string           default(""), not null
#  type       :integer          default(NULL), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bounce_emails_on_email  (email) UNIQUE
#

FactoryBot.define do
  factory :bounce_email do
    type { 'bounce' }
    sequence(:email) { |n| "test#{n}@example.com" }
  end
end

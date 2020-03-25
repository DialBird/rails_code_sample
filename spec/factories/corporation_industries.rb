# frozen_string_literal: true

# == Schema Information
#
# Table name: corporation_industries
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  industry_id    :bigint(8)
#
# Indexes
#
#  index_corporation_industries_on_corporation_id  (corporation_id)
#  index_corporation_industries_on_industry_id     (industry_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (industry_id => industries.id)
#

FactoryBot.define do
  factory :corporation_industry do
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: corporation_sites
#
#  id             :bigint(8)        not null, primary key
#  category       :integer          default(NULL), not null
#  url            :string           default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#
# Indexes
#
#  index_corporation_sites_on_corporation_id  (corporation_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#

FactoryBot.define do
  factory :corporation_site do
  end
end

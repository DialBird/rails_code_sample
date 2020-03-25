# frozen_string_literal: true

# == Schema Information
#
# Table name: browse_pro_licenses
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  pro_id         :bigint(8)
#
# Indexes
#
#  index_browse_pro_licenses_on_corporation_id  (corporation_id)
#  index_browse_pro_licenses_on_pro_id          (pro_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_id => users.id)
#

FactoryBot.define do
  factory :browse_pro_license do
  end
end

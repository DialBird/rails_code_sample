# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_industries
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  industry_id :bigint(8)
#  pro_info_id :bigint(8)
#
# Indexes
#
#  index_pro_industries_on_industry_id  (industry_id)
#  index_pro_industries_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (industry_id => industries.id)
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

FactoryBot.define do
  factory :pro_industry do
    pro_info { nil }
    industry { nil }
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: industries # 業界（マスターデータ）
#
#  id                   :bigint(8)        not null, primary key
#  name                 :string           default(""), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  industry_category_id :bigint(8)
#
# Indexes
#
#  index_industries_on_industry_category_id  (industry_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (industry_category_id => industry_categories.id)
#

FactoryBot.define do
  factory :industry do
  end
end

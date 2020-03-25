# frozen_string_literal: true

# == Schema Information
#
# Table name: industry_categories # 業界カテゴリー（マスターデータ)
#
#  id         :bigint(8)        not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :industry_category do
    name { 'IT・通信' }
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: profession_categories # 職種カテゴリー（マスターデータ)
#
#  id         :bigint(8)        not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :profession_category do
    name { '経営/事業開発' }
  end
end

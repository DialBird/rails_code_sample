# frozen_string_literal: true

# == Schema Information
#
# Table name: professions # 職種（マスターデータ）
#
#  id                     :bigint(8)        not null, primary key
#  name                   :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  profession_category_id :bigint(8)
#
# Indexes
#
#  index_professions_on_profession_category_id  (profession_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (profession_category_id => profession_categories.id)
#

FactoryBot.define do
  factory :profession do
    name { 'エンジニア' }
    profession_category_id { ProfessionCategory.first.id }
  end
end

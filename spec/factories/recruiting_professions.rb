# frozen_string_literal: true

# == Schema Information
#
# Table name: recruiting_professions # 募集している職種
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  profession_id  :bigint(8)        default(0), not null
#
# Indexes
#
#  index_recruiting_professions_on_corporation_id  (corporation_id)
#  index_recruiting_professions_on_profession_id   (profession_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (profession_id => professions.id)
#

FactoryBot.define do
  factory :recruiting_profession do
    association :corporation
    profession_id { Profession.first.id }
  end
end

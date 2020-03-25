# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_professions
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pro_info_id   :bigint(8)
#  profession_id :bigint(8)
#
# Indexes
#
#  index_pro_professions_on_pro_info_id    (pro_info_id)
#  index_pro_professions_on_profession_id  (profession_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#  fk_rails_...  (profession_id => professions.id)
#

FactoryBot.define do
  factory :pro_profession do
    pro_info { nil }
    profession { nil }
  end
end

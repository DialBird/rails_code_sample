# frozen_string_literal: true

# == Schema Information
#
# Table name: user_relations
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  former_id  :bigint(8)
#  latter_id  :bigint(8)
#
# Indexes
#
#  index_user_relations_on_former_id                (former_id)
#  index_user_relations_on_former_id_and_latter_id  (former_id,latter_id) UNIQUE
#  index_user_relations_on_latter_id                (latter_id)
#
# Foreign Keys
#
#  fk_rails_...  (former_id => users.id)
#  fk_rails_...  (latter_id => users.id)
#

FactoryBot.define do
  factory :user_relation do
    association :former, factory: :user
    association :latter, factory: :user
  end
end

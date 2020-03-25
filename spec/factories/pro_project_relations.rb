# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_project_relations
#
#  id                            :bigint(8)        not null, primary key
#  memo_for_orderer              :text
#  memo_for_pro                  :text
#  review_star_count_for_orderer :integer          default(0), not null
#  review_star_count_for_pro     :integer          default(0), not null
#  state_for_orderer             :integer          default("not_react"), not null
#  state_for_pro                 :integer          default("not_react"), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  pro_id                        :bigint(8)
#  project_id                    :bigint(8)
#
# Indexes
#
#  index_pro_project_relations_on_pro_id      (pro_id)
#  index_pro_project_relations_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_id => users.id)
#  fk_rails_...  (project_id => projects.id)
#

FactoryBot.define do
  factory :pro_project_relation do
    association :pro
    association :project
  end
end

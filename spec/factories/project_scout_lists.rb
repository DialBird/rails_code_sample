# frozen_string_literal: true

# == Schema Information
#
# Table name: project_scout_lists
#
#  id            :bigint(8)        not null, primary key
#  scout_message :text             default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_id    :bigint(8)
#  scout_list_id :bigint(8)
#
# Indexes
#
#  index_project_scout_lists_on_project_id     (project_id)
#  index_project_scout_lists_on_scout_list_id  (scout_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (scout_list_id => scout_lists.id)
#

FactoryBot.define do
  factory :project_scout_list do
    association :project
    association :scout_list
    scout_message { 'スカウトメッセージ' }
  end
end

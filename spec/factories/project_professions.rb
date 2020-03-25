# frozen_string_literal: true

# == Schema Information
#
# Table name: project_professions
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  profession_id :bigint(8)
#  project_id    :bigint(8)
#
# Indexes
#
#  index_project_professions_on_profession_id  (profession_id)
#  index_project_professions_on_project_id     (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (profession_id => professions.id)
#  fk_rails_...  (project_id => projects.id)
#

FactoryBot.define do
  factory :project_profession do
  end
end

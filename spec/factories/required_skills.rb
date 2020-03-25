# frozen_string_literal: true

# == Schema Information
#
# Table name: required_skills
#
#  id         :bigint(8)        not null, primary key
#  title      :string           default(""), not null # スキル名
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer          default(0), not null  # プロジェクトID
#
# Foreign Keys
#
#  required_skills_project_id_fk  (project_id => projects.id)
#

FactoryBot.define do
  factory :required_skill do
    association :project
    title { 'タイトル' }
  end
end

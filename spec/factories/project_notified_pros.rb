# frozen_string_literal: true

# == Schema Information
#
# Table name: project_notified_pros
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pro_id     :bigint(8)
#  project_id :bigint(8)
#
# Indexes
#
#  index_project_notified_pros_on_pro_id      (pro_id)
#  index_project_notified_pros_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_id => users.id)
#  fk_rails_...  (project_id => projects.id)
#

FactoryBot.define do
  factory :project_notified_pro do
  end
end

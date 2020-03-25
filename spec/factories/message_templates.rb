# frozen_string_literal: true

# == Schema Information
#
# Table name: message_templates
#
#  id             :bigint(8)        not null, primary key
#  content        :text             default(""), not null
#  type           :integer          default(NULL), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#
# Indexes
#
#  index_message_templates_on_corporation_id  (corporation_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#

FactoryBot.define do
  factory :message_template do
  end
end

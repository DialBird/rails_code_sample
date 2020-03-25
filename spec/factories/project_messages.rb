# frozen_string_literal: true

# == Schema Information
#
# Table name: project_messages
#
#  id                   :bigint(8)        not null, primary key
#  attachment           :string
#  content              :text             default(""), not null
#  from_type            :integer          default(NULL), not null
#  is_first             :boolean          default(FALSE), not null # チャット内の最初のメッセージかの判定に使う
#  is_read              :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  project_chat_room_id :bigint(8)
#
# Indexes
#
#  index_project_messages_on_project_chat_room_id  (project_chat_room_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_chat_room_id => project_chat_rooms.id)
#

FactoryBot.define do
  factory :project_message do
    content { 'メッセージ内容' }
    from_type { 'from_pro' }
  end
end

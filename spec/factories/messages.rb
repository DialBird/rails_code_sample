# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id                    :bigint(8)        not null, primary key
#  attachment            :string
#  content               :text             default(""), not null
#  is_read               :boolean          default(FALSE), not null
#  message_fromable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  chat_room_id          :bigint(8)
#  message_fromable_id   :bigint(8)
#
# Indexes
#
#  index_messages_on_chat_room_id                                   (chat_room_id)
#  index_messages_on_message_fromable_id_and_message_fromable_type  (message_fromable_id,message_fromable_type)
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#

FactoryBot.define do
  factory :message do
    association :chat_room
    association :message_fromable, factory: :user
    content { 'メッセージ内容' }
  end
end

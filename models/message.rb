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

class Message < ApplicationRecord
  ATTRIBUTES = %i[
    attachment
    chat_room_id
    content
  ].freeze

  mount_uploader :attachment, AttachmentUploader

  belongs_to :chat_room
  belongs_to :message_fromable, polymorphic: true

  validates :content, presence: true
  validate :from_member_in_chat_room?

  def from_orderer?
    message_fromable.is_a?(Corporation)
  end

  private

  def from_member_in_chat_room?
    return if from_orderer? && message_fromable == chat_room.corporation
    return if !from_orderer? && message_fromable == chat_room.pro

    errors.add(:base, '発言できない人です')
  end
end

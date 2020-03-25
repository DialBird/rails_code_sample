# frozen_string_literal: true

# == Schema Information
#
# Table name: chat_rooms
#
#  id                          :bigint(8)        not null, primary key
#  is_notify_unread_to_orderer :boolean          default(FALSE), not null
#  is_notify_unread_to_pro     :boolean          default(FALSE), not null
#  is_orderer_unread           :boolean          default(FALSE), not null
#  is_pro_unread               :boolean          default(FALSE), not null
#  last_message_at             :datetime         not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  corporation_id              :bigint(8)
#  pro_id                      :bigint(8)
#
# Indexes
#
#  index_chat_rooms_on_corporation_id  (corporation_id)
#  index_chat_rooms_on_pro_id          (pro_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (pro_id => users.id)
#

class ChatRoom < ApplicationRecord
  belongs_to :corporation
  belongs_to :pro, class_name: 'User'
  has_one :latest_message, -> { order(id: :desc) }, class_name: 'Message'
  has_many :messages, dependent: :destroy, inverse_of: :chat_room

  validate :pro_and_corporation_should_be_unique, on: :create

  private

  def pro_and_corporation_should_be_unique
    return unless ChatRoom.exists?(corporation_id: corporation_id, pro_id: pro_id)

    errors.add(:base, '既にメッセージルームが作成されています')
  end
end

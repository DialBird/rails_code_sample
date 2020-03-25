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

FactoryBot.define do
  factory :chat_room do
    association :corporation
    association :pro
  end
end

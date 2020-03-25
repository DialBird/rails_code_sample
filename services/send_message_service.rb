# frozen_string_literal: true

# WHAT_FOR
# 二通目以降の個別メッセージを送信する時に使う
#
# BEFORE_YOU_USE
# ChatRoomPolicy.new(current_user, chat_room).messagable?でcurrent_userとchat_roomの確認をとる
# その後、current_userがプロ人材側ならfromに:pro、そうでないなら:ordererを入れる
#
# UPDATED_TABLES
# ・ChatRoom
# ・Message
#
# WILL_RETURN
# ・Boolean

class SendMessageService
  attr_reader :chat_room, :message

  def initialize(message)
    @chat_room = message.chat_room
    @message = message
  end

  def call
    ActiveRecord::Base.transaction do
      message.save!
      if message.from_orderer?
        chat_room.update!(last_message_at: Time.current, is_pro_unread: true)
      else
        chat_room.update!(last_message_at: Time.current, is_orderer_unread: true)
      end
    end

    # NOTE: 受注者からのメッセージなら発注会社の会社員全員に、発注者からのメッセージなら受注者一人にメールを送信
    if message.from_orderer?
      pro = chat_room.pro
      MessageMailer.new_arrival(message, pro).deliver_later
    else
      chat_room.corporation.workers.each do |worker|
        MessageMailer.new_arrival(message, worker).deliver_later
      end
    end

    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @SendMessageService
      Msg: #{e.class} #{e.message}
    LOG
    false
  end
end

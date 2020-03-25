# frozen_string_literal: true

# WHAT_FOR
# チャットルームを作成し、会社側からの最初のメッセージを送る
#
# BEFORE_YOU_USE
# ・Form::ChatRoom#valid?
#
# UPDATED_TABLES
# ・ChatRoom
# ・Message

class CreateChatRoomAndFirstMessageService
  attr_reader :chat_room, :message

  def initialize(form_chat_room)
    @chat_room = form_chat_room.chat_room
    @message = form_chat_room.message
  end

  def call
    ActiveRecord::Base.transaction do
      chat_room.save!
      message.save!
    end

    # NOTE: チャットが作られた直後に、プロ側に通知メールが飛ぶ（#128）
    MessageMailer.first_time_message(chat_room).deliver_later

    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @CreateChatRoomAndFirstMessageService
      Msg: #{e.class} #{e.message}
    LOG
    false
  end
end

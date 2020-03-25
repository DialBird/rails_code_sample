# frozen_string_literal: true

class Form::ChatRoom
  include ActiveModel::Model
  include ActiveModel::Attributes

  ATTRIBUTES = %i[attachment content pro_id].freeze

  attr_accessor :chat_room, :corporation, :message, :pro

  attribute :attachment, :binary
  attribute :content, :string, default: ''
  attribute :corporation_id, :integer
  attribute :pro_id, :integer

  validates :content, presence: true
  validate :corporation_should_be_present
  validate :pro_should_be_present
  # NOTE: 順番的に一番最後にバリデーションする必要がある
  validate :chat_room_should_be_unique

  def initialize(attributes)
    super(attributes)
    @corporation = ::Corporation.find_by(id: corporation_id)
    @pro = ::User.joins(:pro_info).find_by(id: pro_id)
    # NOTE: 発注者から個別メッセージが送られるので、プロの未読スイッチもオンにしておく(#589)
    @chat_room = ::ChatRoom.new(corporation: corporation,
                                pro: pro,
                                is_pro_unread: true,
                                last_message_at: Time.current)
    @message = ::Message.new(chat_room: chat_room,
                             message_fromable: corporation,
                             content: content,
                             attachment: attachment)
  end

  private

  def chat_room_should_be_unique
    # NOTE: valid?がエラーになるとしたら、可能性として「すでにcorporationとproの組み合わせが存在する場合」だけなので
    return if chat_room.valid?

    errors.add(:base, 'すでにチャットルームができています')
  end

  def corporation_should_be_present
    return if corporation.present?

    errors.add(:base, '無効な会社IDです')
  end

  def pro_should_be_present
    return if pro.present?

    errors.add(:base, '無効なプロIDです')
  end
end

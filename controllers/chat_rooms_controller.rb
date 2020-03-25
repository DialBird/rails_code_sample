# frozen_string_literal: true

class ChatRoomsController < ApplicationController
  layout 'chat_room', only: :index

  def index
    chat_rooms = policy_scope(:chat_room).preload(:latest_message, corporation: :created_by, pro: :pro_info).order(last_message_at: :desc)
    @pagy, chat_rooms = pagy(chat_rooms, items: Settings.paginate.chat_room_per, size: [2, 2, 2, 2])
    @chat_room_index_presenters = chat_rooms.map { |cr| ChatRoomIndexPresenter.new(current_user: current_user, chat_room: cr) }
  end

  def show
    chat_room = ChatRoom.find(params[:id])
    authorize chat_room
    @chat_room_show_presenter = ChatRoomShowPresenter.new(current_user: current_user, chat_room: chat_room)
    MarkMessagesAsReadService.new(current_user, chat_room).call
  rescue Pundit::NotAuthorizedError
    corporation = chat_room.corporation
    # NOTE: 所属する会社のチャットルームの場合でだけ、メッセージ付きリダイレクト
    raise Pundit::NotAuthorizedError unless corporation.worker?(current_user)

    flash[:danger] = "そのチャットルームを閲覧するためには、現在の会社を「#{corporation.name}」に切り替える必要があります"
    redirect_to chat_rooms_path
  end

  def new
    @pro = authorize User.find(params[:pro_id]), :chat_room_creatable?, policy_class: ProPolicy
    @form_chat_room = Form::ChatRoom.new(pro_id: params[:pro_id])
  end

  def create
    @pro = authorize User.find(form_params[:pro_id]), :chat_room_creatable?, policy_class: ProPolicy
    @form_chat_room = Form::ChatRoom.new(form_params.merge(corporation_id: current_corporation.id))
    if @form_chat_room.valid? && CreateChatRoomAndFirstMessageService.new(@form_chat_room).call
      flash[:success] = 'メッセージが送信されました'
      redirect_to chat_room_path(@form_chat_room.chat_room)
    else
      Rails.logger.fatal(<<~LOG)
        Error @ChatRoomsController#create
        Error: #{@form_chat_room.errors.full_messages}
      LOG
      flash[:error] = 'メッセージの送信に失敗しました'
      render :new
    end
  end

  private

  def form_params
    params.require(:form_chat_room).permit(Form::ChatRoom::ATTRIBUTES)
  end
end

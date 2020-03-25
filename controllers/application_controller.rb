# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # include BasicAuthentication if ENV['IS_STAGING']
  include Pagy::Backend
  include Pundit

  before_action :authenticate_user!
  before_action :store_user_location!, if: :storable_location?
  before_action :redirect_to_setup_if_settings_required_user, if: :user_signed_in?, unless: :devise_controller?

  add_flash_types :success, :info, :warning, :danger

  helper_method :current_corporation,
                :pro_corporation_and_full_name_with_status,
                :pro_full_name_with_status,
                :pro_profile_image_url_with_status,
                :unread_chat_rooms?,
                :unread_notifications?,
                :unread_project_chat_rooms?

  unless Rails.env.development?
    rescue_from Exception,                      with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActiveRecord::RecordNotFound,   with: :render_404
    rescue_from Pundit::NotAuthorizedError,     with: :render_404
  end

  def current_corporation
    current_user.current_corporation
  end

  # NOTE: pro_full_name_with_status, pro_profile_image_url_with_statusは
  # 非公開・プラン関連のメソッドなのでひとまとめにしておきたい

  # FIXME: テストを書きたいけど、どうやって書いていいかわからない
  # NOTE: ログイン中のユーザー・およびプロのステータスに応じたプロのフルネームを取得する
  def pro_full_name_with_status(pro)
    return unless pro.pro_info

    # NOTE: プロの名前の閲覧権限がある場合は表示。それ以外は「＊＊＊＊＊」（#574）
    full_name = ProPolicy.new(current_user, pro).full_name? ? pro.full_name : '＊＊＊＊＊'
    # NOTE: 退会済みの場合は【退会済】をつける
    full_name = "【退会済】 #{full_name}" unless pro.active?
    full_name
  end

  def pro_corporation_and_full_name_with_status(pro)
    return unless pro.pro_info

    # NOTE: 「会社名＋名前」は「名前」と同じ閲覧権限とする。閲覧権限がある場合は表示。それ以外は「＊＊＊＊＊」（#574）
    pro_corporation_and_full_name = "#{pro.pro_info.corporation_name}<br>#{pro.full_name}".html_safe
    full_name = ProPolicy.new(current_user, pro).full_name? ? pro_corporation_and_full_name : '＊＊＊＊＊'
    # NOTE: 退会済みの場合は【退会済】をつける
    full_name = "【退会済】<br>#{full_name}".html_safe unless pro.active?
    full_name
  end

  # FIXME: テストを書きたいけど、どうやって書いていいかわからない
  # NOTE: ログイン中のユーザー・およびプロのステータスに応じたプロのプロファイル画像URLを取得する
  def pro_profile_image_url_with_status(pro)
    return unless pro.pro_info
    # NOTE: 退会済みの場合はデフォルト画像にする
    return pro.profile_image.default_url unless pro.active?

    ProPolicy.new(current_user, pro).profile? ? pro.profile_image_url : pro.profile_image.default_url
  end

  def routing_error(msg = '')
    raise ActionController::RoutingError, "No route matches: #{msg || params[:path]}"
  end

  protected

  # around_actionでアクションに付与することでBulletをskip
  def skip_bullet
    Bullet.enable = false
    yield
    Bullet.enable = true
  end

  private

  def storable_location?
    # HACK: devise_controllerを外して置かないと、facebookログインといった
    # callbackを使う系が無限リクエストを起こしてしまう
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.fullpath.start_with?('/common_friends/') &&
      !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def redirect_to_setup_if_settings_required_user
    return if current_user.settings_completed?

    redirect_to setup_path
  end

  def render_404
    if request.format.to_sym == :json
      render json: { error: '404 error' }, status: :not_found
    else
      render template: 'pages/404', status: 404, layout: 'page'
    end
  end

  def render_500(err = nil)
    logger.fatal(<<~LOG)
      500 Error message starts
      #{err.class} (#{err.message}):
      #{Rails.backtrace_cleaner.clean(err.backtrace).join("\n").indent(1)}
    LOG

    if request.format.to_sym == :json
      render json: { error: '500 error' }, status: :internal_server_error
    else
      render template: 'pages/500', status: 500, layout: 'page'
    end
  end

  def authenticate_admin_user!
    authenticate_user!
    return if current_user.email == Settings.email.support

    flash[:alert] = '管理者用ページです。権限があるアカウントでログインしてください。'
    redirect_to root_path
  end

  def unread_chat_rooms?
    return unless user_signed_in?

    GetCurrentUserUnreadChatRoomsQuery.new(current_user).call.present?
  end

  def unread_notifications?
    current_user.notifications.any? { |n| !n.is_checked }
  end

  def unread_project_chat_rooms?
    return unless user_signed_in?

    GetCurrentUserUnreadProjectChatRoomsQuery.new(current_user).call.present?
  end
end

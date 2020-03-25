# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  DEFAULT_DESCRIPTION = 'サンプル'

  def current_corporation_switchable?
    user_signed_in? && current_user.corporations.size > 1
  end

  def default_meta_tags
    {
      charset: 'utf-8',
      reverse: true,
      description: DEFAULT_DESCRIPTION,
      keywords: 'SOKUDAN',
      viewport: 'width=device-width,initial-scale=1.0,minimum-scale=1.0',
      og: meta_og,
      twitter: {
        card: 'summary_large_image',
        title: meta_title,
        description: meta_description
      },
      fb: face_book_id
    }
  end

  def meta_title
    content_for(:meta_title) || 'SOKUDAN'
  end

  def meta_description
    content_for(:meta_description) || DEFAULT_DESCRIPTION
  end

  def meta_og_image
    content_for(:meta_og_image)
  end

  def face_book_id
    {
      app_id: 12345
    }
  end

  def facebook_share_project_link(project)
    "https://www.facebook.com/sharer/sharer.php?u=#{top_project_url(project)}"
  end

  def meta_og
    {
      title: meta_title,
      type: 'website',
      description: meta_description,
      url: request.original_url,
      image: meta_og_image
    }
  end

  def display_errors(record)
    messages = record.errors.full_messages
    return if messages.blank?

    content_tag(:div, class: 'pa10 parsley-error') do
      content_tag(:ul) do
        messages.each do |m|
          concat content_tag(:li, '● ' + m, class: 'parsley-error-item')
        end
      end
    end
  end

  def display_flash
    flash.each do |type, msg|
      # Deviseのセッションタイムアウト時のflashは無視する
      next if type == 'timedout'

      type = 'success' if type == 'notice'
      type = 'error' if %w[alert danger].include? type
      # NOTE: home画面は全体が緑だから
      type = 'warning' if controller_name == 'home' && type == 'success'

      # NOTE: サインアップ時のフラッシュだけ表示時間を長くする
      concat content_tag(:script, <<~SCRIPT.html_safe)
        #{'toastr.options["timeOut"] = 600000' if msg == I18n.t('devise.registrations.signed_up_but_unconfirmed')}
        toastr.#{type}("#{msg}");
      SCRIPT
    end
    nil
  end

  def selectable_years(options = {})
    start_year = options.delete(:start_year) || Settings.db.min_birth_year
    end_plus = options.delete(:end_plus) || 0
    end_year = Date.today.year + end_plus
    (start_year..end_year).to_a.map do |year|
      Hashie::Mash.new(id: year, name: "#{year}年")
    end
  end

  def selectable_months
    (1..12).to_a.map do |month|
      Hashie::Mash.new(id: month, name: "#{month}月")
    end
  end

  def twitter_share_project_link(project)
    url = top_project_url(project)
    tags = 'aaa,bbb'
    "https://twitter.com/intent/tweet?original_referer=#{request.url}&text=#{project.title}&url=#{url}&hashtags=#{tags}"
  end

  def nl2br(str)
    str = html_escape(str)
    str = str.gsub(/\r\n|\r|\n/, '<br/>')
    url_reg = URI.regexp(%w[http https])
    str = str.gsub(url_reg) { |url| "<a href='#{url}' target='_blank'>#{url}</a>" }
    str.html_safe
  end

  def window_open_script(url, window_name)
    "window.open('#{url}', '#{window_name}', 'top=50,left=50,width=600,height=450,scrollbars=1,resizable=1');"
  end
end

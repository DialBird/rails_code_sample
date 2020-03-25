# frozen_string_literal: true

# WHAT_FOR
# 新規Corporation作成のロジック
#
# UPDATED_TABLES
# - Corporation
# - CorporationUser
# - MessageTemplate
# - Plan
# - User

class AttachCorporationToUserService
  attr_reader :corporation, :user

  def initialize(corporation)
    @corporation = corporation
    @user = corporation.created_by
  end

  def call
    return false if corporation.persisted?

    ActiveRecord::Base.transaction do
      corporation.save!
      CorporationUser.create!(corporation: corporation, user: user)
      # FIXME: multi_message_templates_available
      MessageTemplate.create_with_default_message!(corporation)
      user.update!(current_corporation_id: corporation.id)
    end

    CorporationMailer.created(corporation, user).deliver_later

    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @AttachCorporationToUserService#call
      Msg: #{e.message}
    LOG

    false
  end
end

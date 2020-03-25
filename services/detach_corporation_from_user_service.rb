# frozen_string_literal: true

# WHAT_FOR
# 会社アカウントから社員を削除する
#
# UPDATED_TABLES
#   ・CorporationUser
#   ・User

class DetachCorporationFromUserService
  attr_reader :corporation, :corporation_user, :corporation_user_policy, :user

  def initialize(user, corporation_admin_worker)
    @user = user
    @corporation = corporation_admin_worker.current_corporation
    @corporation_user = CorporationUser.find_by(user: user, corporation: @corporation)
    @corporation_user_policy = CorporationUserPolicy.new(corporation_admin_worker, @corporation_user)
  end

  def call
    return false unless corporation_user_policy.destroy?

    # NOTE: 他の会社がない場合は、現在の会社はnilになる
    next_corporation = user.corporations.where.not(id: corporation.id).first
    ActiveRecord::Base.transaction do
      user.update!(current_corporation: next_corporation)
      corporation_user.destroy!
    end

    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @DetachCorporationFromUserService#call
      Msg: #{e.message}
    LOG

    false
  end
end

# frozen_string_literal: true

# WHAT_FOR
# 案件応募処理
#
# BEFORE_YOU_USE
# ・Form::Apply#valid?
#
# UPDATED_TABLES
# ・BrowseProLicense
# ・ProjectChatRoom
# ・ProjectMessage
# ・ProProjectRelation

class OperateApplyProcedureService
  attr_reader :browse_pro_license,
              :corporation,
              :pro_project_relation,
              :project,
              :project_chat_room,
              :project_message

  def initialize(form_apply)
    @pro_project_relation = form_apply.pro_project_relation
    @project_chat_room = form_apply.project_chat_room
    @project_message = form_apply.project_message
    @browse_pro_license = form_apply.browse_pro_license
    @project = form_apply.project
    @corporation = @project.corporation
  end

  def call
    ActiveRecord::Base.transaction do
      pro_project_relation.save!
      project_chat_room.save!
      project_message.save!
      browse_pro_license.save!
      project_chat_room.update!(last_message_at: Time.current, is_orderer_unread: true)
    end

    corporation.workers.each do |worker|
      ProjectMailer.applied(project, project_chat_room.pro, project_chat_room, worker).deliver_later
    end

    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @OperateApplyProcedureService
      Msg: #{e.class} #{e.message}
    LOG
    false
  end
end

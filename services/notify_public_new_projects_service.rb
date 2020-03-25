# frozen_string_literal: true

# WHAT_FOR
# 新しい案件が登録されましたよ通知
#
# UPDATED_TABLES
# ・ProjectNotifiedPro

class NotifyPublicNewProjectsService
  attr_reader :mail_list

  def initialize(from:, to:)
    projects = Project.opened.where(application_open_at: from..to, is_private: false)

    @mail_list = {}
    projects.each do |project|
      pros = GetProsToWhomSendProjectNotificationQuery.new(project).call
      pros.each do |pro|
        if @mail_list[pro.id]
          @mail_list[pro.id] << project.id
        else
          @mail_list[pro.id] = [project.id]
        end
      end
    end
  end

  def call
    # NOTE: transaction処理に成功した時だけメールが送られるようにしている
    ActiveRecord::Base.transaction do
      mail_list.each do |pro_id, project_ids|
        # NOTE: プロが通知をオフにしていたらカウントしない（メールを送らないから）
        next unless User.find(pro_id).pro_info.is_new_project_notice_on

        project_ids.each do |project_id|
          ProjectNotifiedPro.find_or_create_by!(pro_id: pro_id, project_id: project_id)
        end
      end
    end

    mail_list.each do |pro_id, project_ids|
      pro = User.find(pro_id)
      ProjectMailer.new_arrival(project_ids, pro).deliver_later
    end
    true
  rescue => e
    Rails.logger.fatal(<<~LOG)
      Error @NotifyPublicNewProjectsService#call
      Msg: #{e.class} #{e.message}
    LOG
    false
  end
end

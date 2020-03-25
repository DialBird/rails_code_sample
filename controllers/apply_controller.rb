# frozen_string_literal: true

class ApplyController < ApplicationController
  def new
    @form_apply = Form::Apply.new(project_id: params[:project_id])
    @project = authorize Project.find(params[:project_id]), :apply?
    @project_professions = @project.project_professions.preload(:profession)
  end

  def create
    @form_apply = Form::Apply.new(form_apply_params.merge(pro_id: current_user.id).to_hash)
    @project = authorize Project.find(form_apply_params[:project_id]), :apply?
    @project_professions = @project.project_professions.preload(:profession)
    if @form_apply.valid? && OperateApplyProcedureService.new(@form_apply).call
      flash[:success] = '応募が完了しました'
      redirect_to project_chat_room_path(id: created_project_chat_room.id)
    else
      error_msg_list = ['応募に失敗しました']
      if @form_apply.errors.full_messages.present?
        @form_apply.errors.full_messages.each { |msg| error_msg_list << "・#{msg}" }
      end
      flash[:error] = error_msg_list.join('<br>')
      render :new
    end
  end

  private

  def created_project_chat_room
    pro_project_relation = ProProjectRelation.find_by(project: @project, pro: current_user)
    ProjectChatRoom.find_by(pro_project_relation: pro_project_relation)
  end

  def form_apply_params
    params.require(:form_apply).permit(Form::Apply::ATTRIBUTES)
  end
end

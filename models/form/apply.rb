# frozen_string_literal: true

class Form::Apply
  include ActiveModel::Model
  include ActiveModel::Attributes

  ATTRIBUTES = %i[attachment content project_id].freeze

  attr_reader :browse_pro_license,
              :pro,
              :pro_project_relation,
              :project,
              :project_chat_room,
              :project_message

  attribute :attachment, :binary
  attribute :content, :string, default: ''
  attribute :pro_id, :integer, default: 0
  attribute :project_id, :integer, default: 0

  validates :content, presence: true
  validates :project_id, presence: true
  validate :pro_and_project_should_be_present
  validate :pro_should_be_applyable, if: -> { project.present? }
  validate :valid_attachment_size, if: -> { attachment.present? }

  def initialize(attributes)
    super(attributes)
    @pro = ::User.find_by(id: pro_id)
    @project = ::Project.find_by(id: project_id)
    @pro_project_relation = ::ProProjectRelation.new(pro: pro, project: project)
    @project_chat_room = ::ProjectChatRoom.new(pro_project_relation: @pro_project_relation)
    @project_message = ::ProjectMessage.new(project_chat_room: @project_chat_room,
                                            from_type: :from_pro,
                                            is_first: true,
                                            content: content,
                                            attachment: attachment)
    @browse_pro_license =
      ::BrowseProLicense.find_or_initialize_by(corporation: @project&.corporation, pro: @pro)
  end

  private

  def pro_should_be_applyable
    return if ProjectPolicy.new(pro, project).apply?

    errors.add(:base, '応募ができない組み合わせです')
  end

  def pro_and_project_should_be_present
    return if pro.present? && project.present?

    errors.add(:base, 'プロ人材IDか案件IDが無効です')
  end

  def valid_attachment_size
    return if attachment.size <= 8.megabytes

    errors.add(:base, '添付ファイルの最大サイズは8MBです')
  end
end

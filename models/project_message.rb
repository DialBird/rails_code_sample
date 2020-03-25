# frozen_string_literal: true

# == Schema Information
#
# Table name: project_messages
#
#  id                   :bigint(8)        not null, primary key
#  attachment           :string
#  content              :text             default(""), not null
#  from_type            :integer          default(NULL), not null
#  is_first             :boolean          default(FALSE), not null # チャット内の最初のメッセージかの判定に使う
#  is_read              :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  project_chat_room_id :bigint(8)
#
# Indexes
#
#  index_project_messages_on_project_chat_room_id  (project_chat_room_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_chat_room_id => project_chat_rooms.id)
#

class ProjectMessage < ApplicationRecord
  ATTRIBUTES = %i[
    attachment
    content
    project_chat_room_id
  ].freeze

  SORRY_MESSAGE_TEMPLATE = <<~MSG.chomp.freeze
    お世話になっております。

    厳正なる選考の結果、誠に残念ではございますが、
    今回は採用を見送らせていただきます。

    多数の企業の中から弊社にご応募いただいたことに感謝するとともに、
    ますますのご活躍をお祈り申し上げます。

    引き続きどうぞよろしくおねがいします。
  MSG

  enum from_type: { from_corporation: 1, from_pro: 2 }

  mount_uploader :attachment, AttachmentUploader

  belongs_to :project_chat_room

  validates :content, presence: true

  class << self
    # 自動見送りメッセージとして作成
    def build_as_auto_sorry_message(project_chat_room)
      new(project_chat_room: project_chat_room,
          from_type: :from_corporation,
          content: sorry_message(project_chat_room.pro))
    end

    private

    def sorry_message(pro)
      "#{pro.full_name}様\n\n" + SORRY_MESSAGE_TEMPLATE
    end
  end
end

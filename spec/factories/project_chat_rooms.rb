# frozen_string_literal: true

# == Schema Information
#
# Table name: project_chat_rooms
#
#  id                      :bigint(8)        not null, primary key
#  is_kicked               :boolean          default(FALSE), not null # 発注者側からメッセージを送ってやりとりを開始したか
#  is_orderer_unread       :boolean          default(FALSE), not null
#  is_pro_unread           :boolean          default(FALSE), not null
#  last_message_at         :datetime         not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  pro_project_relation_id :bigint(8)
#
# Indexes
#
#  index_project_chat_rooms_on_pro_project_relation_id  (pro_project_relation_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_project_relation_id => pro_project_relations.id)
#

FactoryBot.define do
  factory :project_chat_room do
  end
end

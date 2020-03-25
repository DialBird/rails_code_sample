# frozen_string_literal: true

# == Schema Information
#
# Table name: reviews # 他のユーザーへのレビュー
#
#  id          :bigint(8)        not null, primary key
#  comment     :text             default(""), not null # 評価コメント
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  relation_id :integer          not null              # 関連性（relation.yml参照）
#  reviewed_id :integer          default(0), not null  # レビューされた側ID
#  reviewer_id :integer          default(0), not null  # レビューアーID
#
# Indexes
#
#  index_reviews_on_reviewer_id_and_reviewed_id  (reviewer_id,reviewed_id) UNIQUE
#
# Foreign Keys
#
#  reviews_reviewed_id_fk  (reviewed_id => users.id)
#  reviews_reviewer_id_fk  (reviewer_id => users.id)
#

FactoryBot.define do
  factory :review do
    association :reviewer, strategy: :create
    association :reviewed, strategy: :create
    relation_id { 1 }
    comment { 'コメント' }
  end
end

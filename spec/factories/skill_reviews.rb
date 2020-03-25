# frozen_string_literal: true

# == Schema Information
#
# Table name: skill_reviews # SkillとReviewの中間テーブル
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  review_id  :integer          default(0), not null  # レビューID
#  skill_id   :integer          default(0), not null  # スキルID
#
# Indexes
#
#  index_skill_reviews_on_skill_id_and_review_id  (skill_id,review_id) UNIQUE
#
# Foreign Keys
#
#  skill_reviews_review_id_fk  (review_id => reviews.id)
#  skill_reviews_skill_id_fk   (skill_id => skills.id)
#

FactoryBot.define do
  factory :skill_review do
    association :skill
    association :review
  end
end

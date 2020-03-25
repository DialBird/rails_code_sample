# frozen_string_literal: true

# == Schema Information
#
# Table name: skills
#
#  id                   :bigint(8)        not null, primary key
#  is_public            :boolean          default(TRUE), not null # 公開フラグ
#  skill_reviews_count  :integer          default(0), not null    # スキルレビューのカウントカラム
#  title                :string           default(""), not null   # スキル名
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  experience_length_id :integer          default(0), not null    # 経験年数（experience_length.yml参照）
#  pro_info_id          :bigint(8)
#
# Indexes
#
#  index_skills_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

FactoryBot.define do
  factory :skill do
    association :pro_info
    title { 'スキル名' }
    experience_length_id { ExperienceLength.first.id }
  end
end

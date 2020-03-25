# frozen_string_literal: true

# == Schema Information
#
# Table name: advises # アドバイスできること
#
#  id              :bigint(8)        not null, primary key
#  detail          :text             default(""), not null    # 経験の詳細
#  is_reward_blank :boolean          default(FALSE), not null # 希望謝礼金額なしフラグ
#  title           :string           default(""), not null    # タイトル
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  industry_id     :integer          default(0), not null     # 業界ID（trade_type.yml参照）
#  min_reward_id   :integer          default(0), not null     # 最低希望単価（min_reward.yml参照）
#  profession_id   :integer          default(0), not null     # 職種タイプ（occupation_type.yml参照）
#  user_id         :integer          default(0), not null     # ユーザーID
#
# Foreign Keys
#
#  advises_user_id_fk  (user_id => users.id)
#  fk_rails_...        (industry_id => industries.id)
#  fk_rails_...        (profession_id => professions.id)
#

FactoryBot.define do
  factory :advise do
    association :user, factory: :pro
    industry_id { Industry.first.id }
    profession_id { Profession.first.id }
    title { 'タイトル' }
    detail { '詳細' }
    min_reward_id { MinReward.first.id }
  end
end

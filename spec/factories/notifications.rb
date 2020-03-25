# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications # 通知
#
#  id              :bigint(8)        not null, primary key
#  is_checked      :boolean          default(FALSE), not null # 通知視聴フラグ
#  thumbnail_image :string
#  title           :string           default(""), not null
#  type            :integer          default(NULL), not null  # 通知タイプ
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          default(0), not null     # ユーザーID
#
# Foreign Keys
#
#  notifications_user_id_fk  (user_id => users.id)
#

FactoryBot.define do
  factory :notification do
    association :user, factory: :pro
    title { '通知タイトル' }
  end
end

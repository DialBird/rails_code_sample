# frozen_string_literal: true

# == Schema Information
#
# Table name: news # お知らせ
#
#  id                 :bigint(8)        not null, primary key
#  category           :integer          default(NULL), not null
#  content            :text             default(""), not null    # 内容
#  date               :datetime                                  # お知らせ日時
#  is_notification_on :boolean          default(TRUE), not null
#  is_public          :boolean          default(FALSE), not null # 公開フラグ
#  title              :string           default(""), not null    # タイトル
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :news do
    category { 'no_category' }
    content { 'コンテンツ' }
    date { Date.today }
    is_public { false }
    title { 'お知らせタイトル' }
  end
end

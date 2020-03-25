# frozen_string_literal: true

# == Schema Information
#
# Table name: carriers # 職歴
#
#  id          :bigint(8)        not null, primary key
#  detail      :text             default(""), not null    # 業務内容
#  end_month   :integer                                   # 終了月
#  end_year    :integer                                   # 終了年
#  is_employed :boolean          default(FALSE), not null # 在職中フラグ
#  start_month :integer                                   # 開始月
#  start_year  :integer                                   # 開始年
#  title       :string           default(""), not null    # 会社名・プロジェクト名
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pro_info_id :bigint(8)
#
# Indexes
#
#  index_carriers_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

FactoryBot.define do
  factory :carrier do
    association :pro_info
    title { '会社名' }
    detail { '主な実績・業務内容' }
  end
end

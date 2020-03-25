# frozen_string_literal: true

# == Schema Information
#
# Table name: corporations
#
#  id                :bigint(8)        not null, primary key
#  address           :string
#  corporation_image :string
#  cover_image       :string
#  department        :string           default(""), not null
#  detail            :text
#  established_at    :date
#  facebook_url      :string
#  instagram_url     :string
#  is_freelance      :boolean          default(FALSE), not null
#  is_no_department  :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  number_of_workers :integer                                   # 従業員数（SOKUDAN内のデータには依存しない）
#  phone             :string           default(""), not null
#  state             :string           default(""), not null
#  twitter_url       :string
#  url               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :bigint(8)
#
# Indexes
#
#  index_corporations_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#

# NOTE: UtilMacros#attach_corporation_toメソッドを使って作ることを推奨
# NOTE: 必ずcreated_byを入れること
FactoryBot.define do
  factory :corporation do
    department { '部署' }
    name { '会社名' }
    phone { '08012345678' }
    url { 'https://example.com' }
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: scout_lists
#
#  id             :bigint(8)        not null, primary key
#  condition_text :string           default("")
#  pro_count      :integer          default(0), not null
#  title          :string           default("")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint(8)
#
# Indexes
#
#  index_scout_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

# NOTE: spec/policies/scout_list_policy_spec.rbのscout_list_factoryのように作成すること
FactoryBot.define do
  factory :scout_list do
    association :user
    condition_text { '条件文' }
    title { 'タイトル' }
  end
end

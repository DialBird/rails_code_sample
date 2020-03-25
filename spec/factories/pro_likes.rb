# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_likes
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  pro_id         :bigint(8)
#
# Indexes
#
#  index_pro_likes_on_corporation_id  (corporation_id)
#  index_pro_likes_on_pro_id          (pro_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (pro_id => users.id)
#

FactoryBot.define do
  factory :pro_like do
  end
end

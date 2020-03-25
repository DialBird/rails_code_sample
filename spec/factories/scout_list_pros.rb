# frozen_string_literal: true

# == Schema Information
#
# Table name: scout_list_pros
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pro_id        :bigint(8)
#  scout_list_id :bigint(8)
#
# Indexes
#
#  index_scout_list_pros_on_pro_id         (pro_id)
#  index_scout_list_pros_on_scout_list_id  (scout_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_id => users.id)
#  fk_rails_...  (scout_list_id => scout_lists.id)
#

FactoryBot.define do
  factory :scout_list_pro do
  end
end

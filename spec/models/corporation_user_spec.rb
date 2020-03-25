# frozen_string_literal: true

# == Schema Information
#
# Table name: corporation_users
#
#  id             :bigint(8)        not null, primary key
#  rank           :integer          default("admin"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  user_id        :bigint(8)
#
# Indexes
#
#  index_corporation_users_on_corporation_id  (corporation_id)
#  index_corporation_users_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe CorporationUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

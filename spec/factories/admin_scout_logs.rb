# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_scout_logs
#
#  id         :bigint(8)        not null, primary key
#  csv_data   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :admin_scout_log do
  end
end

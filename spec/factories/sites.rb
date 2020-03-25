# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id          :bigint(8)        not null, primary key
#  type        :integer          default("other"), not null
#  url         :string           default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pro_info_id :bigint(8)
#
# Indexes
#
#  index_sites_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

FactoryBot.define do
  factory :site do
  end
end

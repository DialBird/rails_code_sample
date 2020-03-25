# frozen_string_literal: true

# == Schema Information
#
# Table name: postscripts # 追記
#
#  id                  :bigint(8)        not null, primary key
#  content             :text             default(""), not null
#  postscriptable_type :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  postscriptable_id   :bigint(8)
#
# Indexes
#
#  index_postscripts_on_postscriptable_type_and_postscriptable_id  (postscriptable_type,postscriptable_id)
#

FactoryBot.define do
  factory :postscript do
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: pro_infos
#
#  id                                  :bigint(8)        not null, primary key
#  bio                                 :text             default(""), not null
#  carrier_url                         :string           default(""), not null    # 経歴がわかるリンク
#  corporation_name                    :string           default(""), not null
#  facebook_url                        :string           default(""), not null
#  github_url                          :string           default(""), not null
#  is_freelance                        :boolean          default(FALSE), not null
#  is_liked_notice_on                  :boolean          default(TRUE), not null
#  is_new_project_notice_on            :boolean          default(TRUE), not null
#  is_public                           :boolean          default(TRUE), not null
#  is_remote                           :boolean          default(FALSE), not null
#  is_scout_notice_on                  :boolean          default(TRUE), not null
#  is_thanks_for_application_notice_on :boolean          default(TRUE), not null  # 応募ありがとうメール通知スイッチ
#  is_weekly_projects_notification_on  :boolean          default(TRUE), not null
#  portfolio_attachment                :string
#  slogan                              :string           default(""), not null
#  twitter_url                         :string           default(""), not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  acceptable_status_id                :integer          default(0), not null
#  asking_wage_id                      :integer          default(0), not null
#  available_time_id                   :integer          default(0), not null
#  user_id                             :bigint(8)
#
# Indexes
#
#  index_pro_infos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe ProInfo, type: :model do
  describe 'validation' do
    subject { build(:pro_info) }
    describe 'corporation_name' do
      context '会社名が未入力でフリーランスチェックが入っていない場合' do
        before do
          subject.corporation_name = ''
          subject.is_freelance = false
        end
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '会社名が未入力でフリーランスチェックが入っている場合' do
        before do
          subject.corporation_name = ''
          subject.is_freelance = true
        end
        it '有効なこと' do
          is_expected.to be_valid
        end
      end
      context '会社名が入力されていて、フリーランスチェックが入っていない場合' do
        before do
          subject.corporation_name = '会社名'
          subject.is_freelance = false
        end
        it '有効なこと' do
          is_expected.to be_valid
        end
      end
    end
  end
end

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

FactoryBot.define do
  factory :pro_info do
    association :user
    acceptable_status_id { 1 }
    asking_wage_id { 1 }
    available_time_id { 1 }
    bio { '自己紹介テキスト' }
    corporation_name { '受注会社名' }
    facebook_url { 'https://www.facebook.com/sample' }
    github_url { 'https://github.com/sample' }
    slogan { 'slogan' }
    twitter_url { 'https://twitter.com/sample' }

    transient do
      profession_id { Profession.first.id }
      industry_id { Industry.first.id }
      skill_title { 'スキル名' }
    end
    after(:build) do |pro_info, evaluator|
      pro_info.pro_professions << build(:pro_profession, pro_info: pro_info, profession_id: evaluator.profession_id)
      pro_info.pro_industries << build(:pro_industry, pro_info: pro_info, industry_id: evaluator.industry_id)
      pro_info.skills << build(:skill, pro_info: pro_info, title: evaluator.skill_title)
    end
  end
end

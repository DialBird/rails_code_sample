# frozen_string_literal: true

# == Schema Information
#
# Table name: projects # 案件
#
#  id                                       :bigint(8)        not null, primary key
#  applicants_count                         :integer          default(0), not null
#  application_close_at                     :date                                              # 募集期限
#  application_open_at                      :datetime
#  detail                                   :text                                              # 案件詳細
#  is_corp_name_secret                      :boolean          default(FALSE), not null
#  is_new_like                              :boolean          default(FALSE), not null
#  is_owner_name_and_common_relation_secret :boolean          default(FALSE), not null
#  is_private                               :boolean          default(FALSE), not null
#  is_remotable                             :boolean          default(TRUE), not null          # リモート可能フラグ
#  is_template                              :boolean          default(FALSE), not null
#  notified_pro_count                       :integer          default(0), not null             # 案件の通知を受け取った人数
#  ogp_image                                :string
#  receive_likes_count                      :integer          default(0), not null             # いいねのカウントカラム
#  remote_type                              :integer          default("full_remote"), not null
#  state                                    :integer
#  title                                    :string           default(""), not null            # 案件名
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  available_time_id                        :integer                                           # 希望稼働時間(available_time.yml参照)
#  corporation_id                           :bigint(8)
#  created_by_id                            :bigint(8)
#  max_budget_id                            :integer                                           # 最高予算（budget.yml参照）
#  min_budget_id                            :integer                                           # 最低予算（budget.yml参照）
#  prefecture_id                            :integer                                           # 都道府県ID（prefecture.yml参照）
#
# Indexes
#
#  index_projects_on_corporation_id  (corporation_id)
#  index_projects_on_created_by_id   (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (created_by_id => users.id)
#

# NOTE: 必ずcorporationを入れること
FactoryBot.define do
  factory :project do
    association :corporation
    association :created_by, factory: :orderer
    available_time_id { AvailableTime.first.id }
    detail { '詳細' }
    max_budget_id { Budget.last.id }
    min_budget_id { Budget.first.id }
    prefecture_id { Prefecture.first.id }
    title { 'プロジェクトサンプル' }
    state { 'opened' }

    transient do
      profession_ids { [Profession.first.id] }
      created_by_id { nil }
    end
    after :build do |project, evaluator|
      evaluator.profession_ids.each do |profession_id|
        project.project_professions << build(:project_profession, project: project, profession_id: profession_id)
      end
      project.created_by_id = evaluator.created_by_id || project.corporation.created_by_id
    end

    factory :draft_project do
      state { 'draft' }
    end
    factory :private_project do
      is_private { true }
    end
  end
end

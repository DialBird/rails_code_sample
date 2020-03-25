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

require 'rails_helper'

RSpec.describe Project, type: :model do
  let!(:orderer) { create(:orderer) }
  let(:corporation) { orderer.current_corporation }
  describe 'validation' do
    subject { build(:project, corporation: corporation) }

    describe 'デフォルトでは' do
      it '有効なこと' do
        is_expected.to be_valid
      end
    end
    describe 'title' do
      context '空欄の時' do
        before { subject.title = '' }
        it '無効なこと' do
          is_expected.to be_invalid
          expect(subject.errors[:title]).to be_present
        end
      end
    end
    describe 'detail' do
      context '空欄の時' do
        before { subject.detail = '' }
        it '無効なこと' do
          is_expected.to be_invalid
          expect(subject.errors[:detail]).to be_present
        end
      end
    end
    %w[Prefecture AvailableTime].each do |enum|
      enum_class = enum.constantize
      field = (enum.underscore + '_id').to_sym
      describe field.to_s do
        context '空欄の場合' do
          before { subject.send("#{field}=", 0) }
          it '無効なこと' do
            is_expected.to be_invalid
          end
        end
        context '範囲内の値の場合' do
          before do
            rand_id = enum_class.all.pluck(:id).sample
            subject.send("#{field}=", rand_id)
          end
          it '有効なこと' do
            is_expected.to be_valid
          end
        end
        context '範囲外の値の場合' do
          before do
            over_id = enum_class.last.id + 1
            subject.send("#{field}=", over_id)
          end
          it '無効なこと' do
            is_expected.to be_invalid
          end
        end
      end
    end
    describe 'application_close_at' do
      it_behaves_like 'valid value', :application_close_at, ''
    end
    describe 'budget' do
      subject { build(:project, corporation: corporation, min_budget_id: min_budget_id, max_budget_id: max_budget_id) }

      context 'min_budgetとmax_budgetが共に未指定の場合' do
        let(:min_budget_id) { 0 }
        let(:max_budget_id) { 0 }
        it 'エラーを返すこと' do
          is_expected.to be_invalid(:detail)
          expect(subject.errors[:base]).to eq [I18n.t('errors.messages.budget_blank')]
        end
      end
      context 'min_budgetとmax_budgetが共に存在し、且つmin_budgetとmax_budgetが同じだった場合' do
        let(:budget) { Budget.all.pluck(:id).sample }
        let(:min_budget_id) { budget }
        let(:max_budget_id) { budget }
        it 'エラーを返すこと' do
          is_expected.to be_invalid(:detail)
          expect(subject.errors[:base]).to eq [I18n.t('errors.messages.budget_not_set_appropriately')]
        end
      end
      context 'min_budgetとmax_budgetが共に存在し、且つmin_budgetがmax_budgetより大きい場合' do
        let(:budgets) { Budget.all.pluck(:id).sample(2) }
        let(:min_budget_id) { budgets.max }
        let(:max_budget_id) { budgets.min }
        it 'エラーを返すこと' do
          is_expected.to be_invalid(:detail)
          expect(subject.errors[:base]).to eq [I18n.t('errors.messages.budget_not_set_appropriately')]
        end
      end
      context 'min_budgetとmax_budgetが共に存在し、且つmin_budgetがmax_budgetより小さい場合' do
        let(:budgets) { Budget.all.pluck(:id).sample(2) }
        let(:min_budget_id) { budgets.min }
        let(:max_budget_id) { budgets.max }
        it 'エラーを返さないこと' do
          is_expected.to be_valid(:detail)
        end
      end
    end
  end
end

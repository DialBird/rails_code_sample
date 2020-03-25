# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetSimilarProjectsService, type: :service do
  describe '#call' do
    let!(:orderer) { create(:orderer) }
    let!(:corporation) { orderer.current_corporation }
    subject { described_class.new(project).call }

    describe 'ソート' do
      let!(:project) { create(:project, corporation: corporation, profession_ids: [1, 2]) }
      let!(:other_project1) { create(:project, corporation: corporation, application_open_at: Date.tomorrow, profession_ids: [1]) }
      let!(:other_project2) { create(:project, corporation: corporation, application_open_at: Date.yesterday, profession_ids: [1]) }
      let!(:other_project3) { create(:project, corporation: corporation, application_open_at: Date.today, profession_ids: [1]) }
      let!(:other_project4) { create(:project, corporation: corporation, application_open_at: Date.today, profession_ids: [1]) }

      it '公開日の降順（日時が同じ場合はIDの降順）であること' do
        is_expected.to eq [other_project1, other_project4, other_project3, other_project2]
      end
    end
    describe 'ステータス' do
      let!(:project) { create(:project, corporation: corporation, profession_ids: [1, 2]) }
      let!(:other_project1) { create(:project, corporation: corporation, state: 'draft', profession_ids: [1]) }
      let!(:other_project2) { create(:project, corporation: corporation, state: 'opened', profession_ids: [1]) }
      let!(:other_project4) { create(:project, corporation: corporation, state: 'closed', profession_ids: [1]) }

      it '引数に入れた案件以外のopenedの案件だけ取得すること' do
        is_expected.to match_array [other_project2]
      end
    end
    describe '職種' do
      # NOTE: 職種IDの1,2,3は全て同じ職種カテゴリ
      let!(:project) { create(:project, corporation: corporation, profession_ids: [2, 3]) }
      let!(:other_project1) { create(:project, corporation: corporation, profession_ids: [1, 2]) }
      let!(:other_project2) { create(:project, corporation: corporation, profession_ids: [3]) }
      let!(:other_project3) { create(:project, corporation: corporation, profession_ids: [2]) }
      let!(:other_project4) { create(:project, corporation: corporation, profession_ids: [1]) }
      let!(:other_project5) { create(:project, corporation: corporation, profession_ids: [20]) }
      let!(:other_project6) { create(:project, corporation: corporation, profession_ids: [2, 3]) }
      context '小カテゴリで一致した案件の次に、大カテゴリで一致した案件した案件を並べて返すこと' do
        it '職種の小カテゴリが一致する案件だけ取得すること' do
          is_expected.to eq [other_project6, other_project3, other_project2, other_project1, other_project4]
        end
      end
    end
  end
end

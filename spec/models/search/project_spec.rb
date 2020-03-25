# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Project, type: :model do
  # NOTE: profession_idは「おすすめ順」ソートのテストのためにつけている
  let!(:current_user) { create(:pro, profession_id: 2) }
  let!(:orderer) { create(:orderer) }
  let(:corporation) { orderer.current_corporation }
  subject { Search::Project.new(Project.all, search_params.merge(current_user: current_user)).matches }

  describe '初期化' do
    subject { Search::Project.new(Project.all, current_user: login_user) }

    context 'ログイン前' do
      let(:login_user) { nil }
      it 'ソートのデフォルトが新着順' do
        expect(subject.sort).to eq Search::Project::SortType::NEW.id
      end
    end
    context 'ログイン後' do
      let(:login_user) { current_user }
      it 'ソートのデフォルトが新着順' do
        expect(subject.sort).to eq Search::Project::SortType::NEW.id
      end
    end
  end
  describe 'ソート' do
    context 'デフォルト（新着順）' do
      let!(:project1) { create(:project, corporation: corporation, application_open_at: Time.current) }
      let!(:project2) { create(:project, corporation: corporation, application_open_at: Time.current) }
      let!(:project3) { create(:project, corporation: corporation, application_open_at: 1.minute.ago) }
      let!(:project4) { create(:project, corporation: corporation, application_open_at: 2.minute.ago) }
      let!(:project5) { create(:project, corporation: corporation, application_open_at: Time.current, state: :closed) }
      let!(:project6) { create(:project, corporation: corporation, application_open_at: 2.minute.ago, state: :closed) }
      let(:search_params) { {} }
      it '募集中の案件を「application_open_atの降順、IDの降順」でソートした後、末尾に終了案件（新着順）を結合した配列を返すこと' do
        is_expected.to eq [project2, project1, project3, project4, project5, project6]
      end
    end
    context 'デフォルト（おすすめ順）' do
      # NOTE: current_userのプロ人材にIDが3,4の職種をつける
      # current_userにはすでにIDが2の職種が紐づいているので、職種は2,3,4となる
      before do
        create(:pro_profession, pro_info: current_user.pro_info, profession_id: 3)
        create(:pro_profession, pro_info: current_user.pro_info, profession_id: 4)
      end
      let!(:project1) { create(:project, profession_ids: [2, 3], corporation: corporation, application_open_at: Time.current) }
      let!(:project2) { create(:project, profession_ids: [1], corporation: corporation, application_open_at: Time.current) }
      let!(:project3) { create(:project, profession_ids: [4], corporation: corporation, application_open_at: 1.minute.ago) }
      let!(:project4) { create(:project, profession_ids: [1, 5], corporation: corporation, application_open_at: 2.minute.ago) }
      let!(:project5) { create(:project, profession_ids: [2, 4], corporation: corporation, application_open_at: Time.current) }
      let!(:project6) { create(:project, profession_ids: [2, 4], corporation: corporation, application_open_at: 2.minute.ago, state: :closed) }
      let!(:project7) { create(:project, profession_ids: [1, 5], corporation: corporation, application_open_at: Time.current, state: :closed) }
      let!(:project8) { create(:project, profession_ids: [2, 4], corporation: corporation, application_open_at: Time.current, state: :closed) }
      let(:search_params) { { sort: Search::Project::SortType::RECOMMEND.id } }
      it '募集中の案件を「ログインユーザーの職種、application_open_atの降順、IDの降順」でソートした後、末尾に終了案件（新着順）を結合した配列を返すこと' do
        # NOTE: project7は本来、職種がユーザーと一致したものではないが、複雑な絞り込みロジックを、あまり重要でない募集終了案件にまで適用するのは
        # アプリへの負荷的なものも考えてあまり得策ではないと判断したので、そのままにしている
        is_expected.to eq [project5, project1, project3, project2, project4, project8, project7, project6]
      end
    end
    context '上限金額が高い順' do
      let!(:project1) { create(:project, corporation: corporation, max_budget_id: 2) }
      let!(:project2) { create(:project, corporation: corporation, max_budget_id: 4) }
      let!(:project3) { create(:project, corporation: corporation, max_budget_id: 2) }
      let!(:project4) { create(:project, corporation: corporation, max_budget_id: 4, state: :closed) }
      let!(:project5) { create(:project, corporation: corporation, max_budget_id: 4, state: :closed) }
      let(:search_params) { { sort: Search::Project::SortType::MAX_WAGE.id } }
      it '募集中の案件を「max_budget_idの降順、IDの降順」でソートした後、末尾に終了案件（新着順）を結合した配列を返すこと' do
        is_expected.to eq [project2, project3, project1, project5, project4]
      end
    end
  end
  describe '検索' do
    describe '職種' do
      let(:profession_category_id) { ProfessionCategory.first.id }
      let!(:project1) { create(:project, corporation: corporation, profession_ids: [1]) }
      let!(:project2) { create(:project, corporation: corporation, profession_ids: [2]) }
      let!(:project3) { create(:project, corporation: corporation, profession_ids: [3]) }
      let!(:project4) { create(:project, corporation: corporation, profession_ids: [1, 2]) }
      let!(:project5) { create(:project, corporation: corporation, profession_ids: [2, 3]) }
      let!(:project6) { create(:project, corporation: corporation, profession_ids: [3, 4]) }
      let(:search_params) { { profession_category_id: profession_category_id, profession_ids: [1, 2] } }

      it '職種で絞り込めること' do
        is_expected.to match_array [project5, project4, project2, project1]
      end
    end
    describe '稼働時間' do
      let(:available_time_ids) { AvailableTime.first(3).pluck(:id) }
      let!(:project1) { create(:project, corporation: corporation, available_time_id: available_time_ids[0]) }
      let!(:project2) { create(:project, corporation: corporation, available_time_id: available_time_ids[1]) }
      let!(:project3) { create(:project, corporation: corporation, available_time_id: available_time_ids[2]) }
      let(:random_id) { available_time_ids.sample }
      let(:search_params) { { available_time_ids: [random_id] } }

      it '稼働時間で絞り込めること' do
        expect(subject.size).to eq 1
        expect(subject.last.available_time).to eq AvailableTime.find(random_id)
      end
    end
    describe 'エリア' do
      let(:pref_ids) { Area.first(3).map { |a| a.prefectures.first.id } }
      let!(:project1) { create(:project, corporation: corporation, prefecture_id: pref_ids[0]) }
      let!(:project2) { create(:project, corporation: corporation, prefecture_id: pref_ids[1]) }
      let!(:project3) { create(:project, corporation: corporation, prefecture_id: pref_ids[2]) }
      let(:random_id) { Area.first(3).pluck(:id).sample }
      let(:search_params) { { area_ids: [random_id] } }

      it 'エリアで絞り込めること' do
        expect(subject.size).to eq 1
        expect(subject.last.prefecture.area).to eq Area.find(random_id).name
      end
    end
    describe 'リモート条件' do
      let!(:project1) { create(:project, corporation: corporation, remote_type: :full_remote) }
      let!(:project2) { create(:project, corporation: corporation, remote_type: :part_remote) }
      let!(:project3) { create(:project, corporation: corporation, remote_type: :no_remote) }

      context 'リモート条件がなしの場合' do
        let(:search_params) { { remote_types: [] } }
        it '全てを返すこと' do
          is_expected.to match_array [project1, project2, project3]
        end
      end
      context 'リモート条件が「full」の場合' do
        let(:search_params) { { remote_types: %w[full_remote] } }
        it 'リモート希望で絞り込めること' do
          is_expected.to match_array [project1]
        end
      end
      context 'リモート条件が「fullとpart」の場合' do
        let(:search_params) { { remote_types: %w[full_remote part_remote] } }
        it 'リモート希望で絞り込めること' do
          is_expected.to match_array [project1, project2]
        end
      end
    end
    describe '募集終了を除く' do
      let!(:draft_project) { create(:project, corporation: corporation, state: 'draft') }
      let!(:open_project) { create(:project, corporation: corporation, state: 'opened') }
      let!(:closed_project) { create(:project, corporation: corporation, state: 'closed') }
      context 'チェックが入っていた場合' do
        let(:search_params) { { is_closed: true } }
        it '募集中案件だけに絞り込むこと' do
          is_expected.to match_array [open_project]
        end
      end
      context 'チェックが入っていない場合' do
        let(:search_params) { { is_closed: false } }
        it '全ての案件を返すこと' do
          is_expected.to match_array [draft_project, open_project, closed_project]
        end
      end
    end
    describe 'スキル名' do
      let!(:project1) { create(:project, corporation: corporation) }
      let!(:project2) { create(:project, corporation: corporation) }
      let!(:project3) { create(:project, corporation: corporation) }
      before do
        project1.required_skills.create(title: 'あいうえお')
        project1.required_skills.create(title: 'ABC')
        project2.required_skills.create(title: 'かきくけこ')
        project3.required_skills.create(title: 'きくけこ')
      end

      context '完全一致するスキル名を持つ案件があった場合' do
        let(:search_params) { { skill_name: 'あいうえお' } }
        it '完全一致で絞り込めること' do
          is_expected.to match_array [project1]
        end
      end
      context '部分一致するスキル名を持つ案件があった場合' do
        let(:search_params) { { skill_name: 'きく' } }
        it '部分一致で絞り込めること' do
          is_expected.to match_array [project2, project3]
        end
      end
      context '小文字でも一致した場合' do
        let(:search_params) { { skill_name: 'abc' } }
        it '大文字小文字関係なく絞り込めること' do
          is_expected.to match_array [project1]
        end
      end
      context 'スペースが前後に入っていた場合' do
        let(:search_params) { { skill_name: ' ABC' } }
        it 'スペースを無くして絞り込めること' do
          is_expected.to match_array [project1]
        end
      end
      context 'スペースだけの場合' do
        let(:search_params) { { skill_name: ' ' } }
        it '検索していないに等しいこと' do
          is_expected.to match_array [project1, project2, project3]
        end
      end
    end
  end
end

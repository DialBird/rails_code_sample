# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Pro, type: :model do
  subject { Search::Pro.new(ProPolicy::Scope.new(nil, User).resolve, search_params).matches }

  describe 'ソート' do
    let!(:pro1) { create(:pro, current_sign_in_at: Time.current, created_at: 1.minute.ago) }
    let!(:pro2) { create(:pro, current_sign_in_at: Time.current, created_at: 2.minute.ago) }
    let!(:pro3) { create(:pro, current_sign_in_at: 1.minute.ago, created_at: Time.current) }
    let!(:pro4) { create(:pro, current_sign_in_at: 2.minute.ago, created_at: 2.minute.ago) }
    context 'デフォルト（新着順）' do
      let(:search_params) { {} }
      it 'current_sign_in_atの降順、IDの降順でソートすること' do
        is_expected.to match_array [pro2, pro1, pro3, pro4]
      end
    end
    context 'ログイン順' do
      let(:search_params) { { sort: Search::Pro::SortType::LOGIN .id } }
      it 'created_atの降順、IDの降順でソートすること' do
        is_expected.to match_array [pro3, pro1, pro2, pro4]
      end
    end
  end
  describe '検索' do
    describe '業界カテゴリー' do
      let(:industry_category_ids) { IndustryCategory.first(3).map { |i| i.industries.first.id } }
      let!(:pro1) { create(:pro, industry_id: industry_category_ids[0]) }
      let!(:pro2) { create(:pro, industry_id: industry_category_ids[1]) }
      let!(:pro3) { create(:pro, industry_id: industry_category_ids[2]) }
      let(:random_id) { IndustryCategory.first(3).pluck(:id).sample }
      let(:search_params) { { industry_category_id: random_id } }
      context '有料ユーザーの場合' do
        it '業界カテゴリーで絞り込めること' do
          expect(subject.size).to eq 1
          expect(subject.last.industries.last.id).to eq IndustryCategory.find(random_id).industries.first.id
        end
      end
    end
    describe '職種' do
      let(:profession_category_id) { ProfessionCategory.first.id }
      let(:professions) { ProfessionCategory.first.professions }
      let!(:pro1) { create(:pro, profession_id: professions.first.id) }
      let!(:pro2) { create(:pro, profession_id: professions.first.id) }
      let!(:pro3) { create(:pro, profession_id: professions.second.id) }
      let!(:pro4) { create(:pro, profession_id: ProfessionCategory.second.professions.first.id) }
      let(:search_params) { { profession_category_id: profession_category_id, profession_ids: profession_ids } }
      before { create(:pro_profession, pro_info: pro1.pro_info, profession_id: professions.second.id) }

      context '職種カテゴリだけ選択' do
        let(:profession_ids) { [] }
        it 'その職種カテゴリに該当するプロを全て絞り込むこと' do
          is_expected.to match_array [pro1, pro2, pro3]
        end
      end
      context '職種を一つだけ選択' do
        let(:profession_ids) { [professions.first.id] }

        it '一つの職種で絞り込めること' do
          is_expected.to match_array [pro1, pro2]
        end
      end
      context '職種を複数選択' do
        let(:profession_ids) { [professions.first.id, professions.second.id] }

        it '複数職種のAND条件で絞り込めること' do
          is_expected.to match_array [pro1]
        end
      end
    end
    describe 'エリア' do
      let(:pref_ids) { Area.first(3).map { |a| a.prefectures.first.id } }
      let!(:pro1) { create(:pro, prefecture_id: Prefecture.find_by(name: '東京都').id) }
      let!(:pro2) { create(:pro, prefecture_id: Prefecture.find_by(name: '千葉県').id) }
      let!(:pro3) { create(:pro, prefecture_id: Prefecture.find_by(name: '大阪府').id) }
      let!(:pro4) { create(:pro, prefecture_id: Prefecture.find_by(name: '海外').id) }
      let(:random_id) { Area.first(3).pluck(:id).sample }
      context '東京を指定' do
        let(:search_params) { { area_ids: [Area.find_by(name: '東京').id] } }
        it '意図したエリアで絞り込めること' do
          expect(subject).to match_array [pro1]
        end
      end
      context '首都圏（東京以外）を指定' do
        let(:search_params) { { area_ids: [Area.find_by(name: '首都圏（東京以外）').id] } }
        it '意図したエリアで絞り込めること' do
          expect(subject).to match_array [pro2]
        end
      end
      context '関西' do
        let(:search_params) { { area_ids: [Area.find_by(name: '関西').id] } }
        it '意図したエリアで絞り込めること' do
          expect(subject).to match_array [pro3]
        end
      end
      context 'その他' do
        let(:search_params) { { area_ids: [Area.find_by(name: 'その他').id] } }
        it '意図したエリアで絞り込めること' do
          expect(subject).to match_array [pro4]
        end
      end
    end
    describe '稼働時間' do
      let!(:pro1) { create(:pro, available_time_id: 1) }
      let!(:pro2) { create(:pro, available_time_id: 2) }
      let!(:pro3) { create(:pro, available_time_id: 3) }
      let(:random_id) { (1..3).to_a.sample }
      let(:search_params) { { available_time_ids: [random_id] } }
      it '稼働時間で絞り込めること' do
        expect(subject.size).to eq 1
        expect(subject.last.pro_info.available_time_id).to eq random_id
      end
    end
    describe '今は忙しいを除く' do
      let!(:pro1) { create(:pro, acceptable_status_id: AcceptableStatus::POSSIBLE.id) }
      let!(:pro2) { create(:pro, acceptable_status_id: AcceptableStatus::CONSUL.id) }
      let!(:pro3) { create(:pro, acceptable_status_id: AcceptableStatus::BUSY.id) }
      context 'is_acceptableがtrueの場合' do
        let(:search_params) { { is_acceptable: true } }
        it '今は忙しい以外で絞り込めること' do
          is_expected.to match_array [pro2, pro1]
        end
      end
      context 'is_acceptableがnilの場合' do
        let(:search_params) { { is_acceptable: nil } }
        it '全部返すこと' do
          is_expected.to match_array [pro3, pro2, pro1]
        end
      end
    end
    describe 'リモート希望' do
      let!(:pro1) { create(:pro, is_remote: true) }
      let!(:pro2) { create(:pro, is_remote: false) }
      context 'is_remoteがtrueの場合' do
        let(:search_params) { { is_remote: true } }
        it 'リモート希望で絞り込めること' do
          is_expected.to match_array [pro1]
        end
      end
      context 'is_remoteがnilの場合' do
        let(:search_params) { { is_remote: nil } }
        it '全部返すこと' do
          is_expected.to match_array [pro2, pro1]
        end
      end
    end
    describe 'Facebook友達' do
      let!(:current_user) { create(:orderer) }
      let!(:pro1) { create(:pro) }
      let!(:pro2) { create(:pro) }
      let!(:pro3) { create(:pro) }
      let(:search_params) { { is_fb_friend: true, current_user: current_user } }
      before do
        allow(GetFriendsQuery).to(receive_message_chain(:new, :call, :ids)
                                    .with(current_user)
                                    .with(no_args)
                                    .with(no_args)
                                    .and_return([pro1.id, pro3.id]))
      end
      it 'FBの知り合いだけを返すこと' do
        is_expected.to match_array [pro3, pro1]
      end
    end
    describe 'スキル名' do
      let!(:pro1) { create(:pro, skill_title: 'ABCDE') }
      let!(:pro2) { create(:pro, skill_title: 'ABCDE') }
      let!(:pro3) { create(:pro, skill_title: 'FGHIJ') }
      let!(:pro4) { create(:pro, skill_title: 'FGH') }
      before do
        create(:skill, title: 'OOO', pro_info: pro1.pro_info)
      end

      context '完全一致するスキル名を持つ案件があった場合' do
        let(:search_params) { { skill_names: 'ABCDE' } }
        it '完全一致で絞り込めること' do
          is_expected.to match_array [pro1, pro2]
        end
      end
      context '部分一致するスキル名を持つ案件があった場合' do
        let(:search_params) { { skill_names: 'FGH' } }
        it '部分一致で絞り込めること' do
          is_expected.to match_array [pro3, pro4]
        end
      end
      context '小文字でも一致した場合' do
        let(:search_params) { { skill_names: 'abc' } }
        it '大文字小文字関係なく絞り込めること' do
          is_expected.to match_array [pro1, pro2]
        end
      end
      context 'スペースが前後に入っていた場合' do
        let(:search_params) { { skill_names: ' ABC' } }
        it 'スペースを無くして絞り込めること' do
          is_expected.to match_array [pro1, pro2]
        end
      end
      context 'スペースだけの場合' do
        let(:search_params) { { skill_names: ' ' } }
        it '検索していないに等しいこと' do
          is_expected.to match_array [pro1, pro2, pro3, pro4]
        end
      end
      describe '複数スキル入力' do
        context 'コンマと句読点だけの文字列の場合' do
          let(:search_params) { { skill_names: '、 , 　,,、 ' } }
          it '検索していないに等しいこと' do
            is_expected.to match_array [pro1, pro2, pro3, pro4]
          end
        end
        context '複数スキル名が正しく入っている場合（パターン１）' do
          let(:search_params) { { skill_names: 'AB, OO' } }
          it '全てのスキルを持っているプロだけ検索されること' do
            is_expected.to match_array [pro1]
          end
        end
        context '複数スキル名が正しく入っている場合（パターン２）' do
          let(:search_params) { { skill_names: 'AB, FG' } }
          it '全てのスキルを持っているプロだけ検索されること' do
            is_expected.to match_array []
          end
        end
      end
    end
  end
end

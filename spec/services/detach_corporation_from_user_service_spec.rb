# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DetachCorporationFromUserService, type: :service do
  describe '#call' do
    let!(:corporation_creater) { create(:orderer) }
    let(:corporation) { corporation_creater.current_corporation }
    let!(:worker) { create(:user, usage_type_id: User::UsageType::ORDERING.id, state: 'settings_completed') }
    let!(:other_corporation_creater) { create(:orderer) }
    let(:other_corporation) { other_corporation_creater.current_corporation }
    before do
      create(:corporation_user, user: worker, corporation: corporation, rank: 'staff')
      create(:corporation_user, user: worker, corporation: other_corporation, rank: 'staff')
      worker.update(current_corporation_id: corporation.id)
    end
    subject { described_class.new(worker, current_user).call }

    describe 'current_user' do
      context '会社の管理者' do
        let(:current_user) { corporation_creater }
        it '削除する社員のcurrent_corporation_idが他の会社になること' do
          expect { subject }.to change { worker.current_corporation }.to other_corporation
        end
        it 'CorporationUserが削除されること' do
          expect { subject }.to change { CorporationUser.count }.by -1
        end
        it 'trueを返すこと' do
          is_expected.to be_truthy
        end
      end
      context '他の会社の管理者' do
        let!(:current_user) { create(:orderer) }
        it 'falseを返すこと' do
          is_expected.to be_falsy
        end
      end
    end
    describe 'current_corporation_id' do
      let(:current_user) { corporation_creater }
      context '他に存在しない場合' do
        before { CorporationUser.find_by(user: worker, corporation: other_corporation).destroy }
        it 'current_corporation_idがnilになること' do
          expect { subject }.to change { worker.current_corporation }.to nil
        end
        it 'CorporationUserが削除されること' do
          expect { subject }.to change { CorporationUser.count }.by -1
        end
        it 'trueを返すこと' do
          is_expected.to be_truthy
        end
      end
      context '他に存在する場合' do
        it '削除する社員のcurrent_corporation_idが他の会社になること' do
          expect { subject }.to change { worker.current_corporation }.to other_corporation
        end
        it 'CorporationUserが削除されること' do
          expect { subject }.to change { CorporationUser.count }.by -1
        end
        it 'trueを返すこと' do
          is_expected.to be_truthy
        end
      end
    end
  end
end

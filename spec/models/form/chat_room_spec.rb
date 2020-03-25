# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::ChatRoom, type: :form_model do
  # 個別メッセージは発注者からしか最初送れないため、current_userは発注者
  let!(:current_user) { create(:orderer) }
  let(:corporation) { current_user.current_corporation }
  let!(:pro) { create(:pro) }

  # 正常パラメーター
  let(:corporation_id) { corporation.id }
  let(:pro_id) { pro.id }
  let(:content) { 'メッセージ内容' }

  subject do
    described_class.new(corporation_id: corporation_id, pro_id: pro_id, content: content)
  end

  describe 'validation' do
    describe '全て正常パラメーター' do
      it '有効なこと' do
        is_expected.to be_valid
      end
    end
    describe 'corporation_id' do
      context '空欄' do
        let(:corporation_id) { '' }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '無効なID' do
        let(:corporation_id) { 99999999 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
    describe 'pro_id' do
      context '空欄' do
        let(:pro_id) { '' }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '発注者のID' do
        let!(:other_orderer) { create(:orderer) }
        let(:pro_id) { other_orderer.id }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '無効なID' do
        let(:pro_id) { 99999999 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
    describe 'content' do
      context '空欄' do
        let(:content) { '' }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
    describe 'ChatRoom' do
      context 'すでに存在する' do
        before { create(:chat_room, pro: pro, corporation: corporation) }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
  end
  describe 'after validation' do
    describe 'ChatRoom' do
      it 'ChatRoomのis_pro_unreadをtrueにすること' do
        expect(subject.chat_room.is_pro_unread).to be_truthy
      end
    end
  end
end

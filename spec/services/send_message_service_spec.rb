# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendMessageService do
  describe '#call' do
    let!(:pro) { create(:pro) }
    let!(:orderer) { create(:orderer) }
    let(:corporation) { orderer.current_corporation }
    let!(:chat_room) { create(:chat_room, pro: pro, corporation: corporation) }
    let(:message) { build(:message, chat_room: chat_room, message_fromable: message_fromable, content: 'メッセージ内容') }
    before do
      # 会社員を二人にする
      user = create(:user)
      create(:corporation_user, corporation: corporation, user: user)

      allow(MessageMailer).to receive_message_chain(:new_arrival, :deliver_later)
    end
    subject { described_class.new(message).call }

    describe 'Error' do
      let(:message_fromable) { pro }
      describe '発生しない' do
        it 'trueを返すこと' do
          is_expected.to be_truthy
        end
      end
      describe 'ActiveRecord::RecordInvalid' do
        before do
          allow_any_instance_of(Message).to receive(:save!).and_raise ActiveRecord::RecordInvalid, 'ok'
        end
        it 'falseを返すこと' do
          is_expected.to be_falsy
        end
      end
    end

    describe '発注者からメッセージを送る場合' do
      let(:message_fromable) { corporation }
      it 'Messageを作成すること' do
        expect { subject }.to change { Message.count }.by 1
      end
      it 'ChatRoomのis_pro_unreadをtrueにすること' do
        expect { subject }.to change { chat_room.reload.is_pro_unread }.to true
      end
      it 'ChatRoomのis_orderer_unreadを更新しないこと' do
        expect { subject }.not_to change { chat_room.reload.is_orderer_unread }
      end
      it 'ChatRoomのlast_message_atを更新すること' do
        expect { subject }.to change { chat_room.reload.last_message_at }
      end
      it 'プロ人材側にメールが送られること' do
        subject
        expect(MessageMailer).to have_received(:new_arrival).once
      end
    end
    describe 'プロからメッセージを送る場合' do
      let(:message_fromable) { pro }
      it 'Messageを作成すること' do
        expect { subject }.to change { Message.count }.by 1
      end
      it 'ChatRoomのis_pro_unreadを更新しないこと' do
        expect { subject }.not_to change { chat_room.reload.is_pro_unread }
      end
      it 'ChatRoomのis_orderer_unreadをtrueにすること' do
        expect { subject }.to change { chat_room.reload.is_orderer_unread }.to true
      end
      it 'ChatRoomのlast_message_atを更新すること' do
        expect { subject }.to change { chat_room.reload.last_message_at }
      end
      it '発注者側にメールが送られること' do
        subject
        expect(MessageMailer).to have_received(:new_arrival).exactly(2).times
      end
    end
  end
end

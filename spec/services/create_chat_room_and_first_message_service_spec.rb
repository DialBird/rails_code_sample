# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateChatRoomAndFirstMessageService do
  describe '#call' do
    let!(:pro) { create(:pro) }
    let!(:orderer) { create(:orderer) }
    let(:corporation) { orderer.current_corporation }
    let(:content) { 'メッセージ内容' }
    let(:form_chat_room) { Form::ChatRoom.new(pro_id: pro.id, corporation_id: corporation.id, content: content) }
    before do
      allow(MessageMailer).to receive_message_chain(:first_time_message, :deliver_later)
    end
    subject { described_class.new(form_chat_room).call }

    describe 'Error' do
      describe '発生しない' do
        it 'trueを返すこと' do
          is_expected.to be_truthy
        end
      end
      describe 'ActiveRecord::RecordInvalid' do
        before do
          allow_any_instance_of(ChatRoom).to receive(:save!).and_raise ActiveRecord::RecordInvalid, 'ok'
        end
        it 'falseを返すこと' do
          is_expected.to be_falsy
        end
      end
    end

    describe 'ユースケース' do
      describe '新規チャットルームを作り、メッセージを投稿する' do
        it 'ChatRoomを作成すること' do
          expect { subject }.to change { ChatRoom.count }.by 1
        end
        it 'Messageを作成すること' do
          expect { subject }.to change { Message.count }.by 1
          expect(Message.last.content).to eq content
        end
        it 'MessageMailer#first_time_messageを呼び出すこと' do
          subject
          expect(MessageMailer).to have_received(:first_time_message).once
        end
      end
    end
  end
end

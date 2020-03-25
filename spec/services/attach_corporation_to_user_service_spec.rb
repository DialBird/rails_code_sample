# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachCorporationToUserService, type: :service do
  describe '#call' do
    let!(:orderer) { create(:user, usage_type_id: User::UsageType::ORDERING.id, state: 'settings_completed') }
    let(:corporation) { build(:corporation, created_by: orderer) }
    before { allow(CorporationMailer).to receive_message_chain(:created, :deliver_later) }
    subject { described_class.new(corporation).call }

    context 'corporationが保存済みの場合' do
      before { corporation.save }
      it 'falseを返すこと' do
        is_expected.to be_falsy
      end
    end
    context '正常に処理が完了した場合' do
      it 'trueを返すこと' do
        is_expected.to be_truthy
      end
      it 'Corporationを作成すること' do
        expect { subject }.to change { Corporation.count }.by 1
      end
      it 'MessageTemplateを作成すること' do
        expect { subject }.to change { MessageTemplate.count }.by 1
      end
      it 'CorporationUserを作成すること' do
        expect { subject }.to change { CorporationUser.count }.by 1
      end
      it 'User#current_corporation_idを更新すること' do
        # FIXME: expect~changeで書いてもうまくいかなかった
        expect(orderer.current_corporation_id).to be_nil
        subject
        expect(orderer.current_corporation_id).to eq corporation.id
      end
      it 'メールをサポートに向けて送信すること' do
        subject
        expect(CorporationMailer).to have_received(:created).once
      end
    end
    context '正常に処理が完了しなかった場合' do
      before { allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::RecordInvalid, 'error') }
      it 'falseを返すこと' do
        is_expected.to be_falsy
      end
      it 'Corporationを作成しないこと' do
        expect { subject }.not_to change { Corporation.count }
      end
      it 'MessageTemplateを作成しないこと' do
        expect { subject }.not_to change { MessageTemplate.count }
      end
      it 'CorporationUserを作成しないこと' do
        expect { subject }.not_to change { CorporationUser.count }
      end
      it 'User#current_corporation_idを更新しないこと' do
        # FIXME: expect~changeで書いてもうまくいかなかった
        expect(orderer.current_corporation_id).to be_nil
        subject
        expect(orderer.current_corporation_id).to be_nil
      end
      it 'メールをサポートに向けて送信しないこと' do
        subject
        expect(CorporationMailer).not_to have_received(:created)
      end
    end
  end
end

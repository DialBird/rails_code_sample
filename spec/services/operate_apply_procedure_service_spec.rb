# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperateApplyProcedureService do
  describe '#call' do
    let!(:pro) { create(:pro) }
    let!(:orderer) { create(:orderer) }
    let(:corporation) { orderer.current_corporation }
    let!(:plan) { create(:plan, corporation: corporation, rank: rank) }
    let!(:project) { create(:project, corporation: corporation) }
    let(:form_apply) { Form::Apply.new(pro_id: pro.id, project_id: project.id, content: 'メッセージ内容') }
    before do
      # 従業員を３人にする
      other_worker1 = create(:orderer)
      other_worker2 = create(:orderer)
      create(:corporation_user, user: other_worker1, corporation: corporation)
      create(:corporation_user, user: other_worker2, corporation: corporation)
      allow(ProjectMailer).to receive_message_chain(:applied, :deliver_later)
    end
    subject { described_class.new(form_apply).call }

    describe 'Error' do
      # FIXME: 時間があればあとで
    end

    # NOTE: フリープランの場合だけで全てのパターンを網羅できる
    describe 'フリープランの発注者の案件に応募' do
      let(:rank) { 'free' }
      it 'ProProjectRelationが作成されること' do
        expect { subject }.to change { ProProjectRelation.count }.by 1
      end
      it 'ProjectChatRoomが作成されること' do
        expect { subject }.to change { ProjectChatRoom.count }.by 1
      end
      it 'プロからのProjectMessageが作成されること' do
        expect { subject }.to change { ProjectMessage.count }.by 1
        expect(ProjectMessage.last.from_type).to eq 'from_pro'
        expect(ProjectMessage.last.is_first).to eq true
      end
      describe 'BrowseProLicense' do
        context '存在する（過去に応募していた）場合' do
          before do
            create(:browse_pro_license, corporation: corporation, pro: pro)
          end
          it 'BrowseProLicenseを作成しないこと' do
            expect { subject }.not_to change { BrowseProLicense.count }
          end
        end
        context '存在しない場合' do
          it 'BrowseProLicenseを作成すること' do
            expect { subject }.to change { BrowseProLicense.count }.by 1
          end
        end
      end
      it 'ProjectMailer#appliedを会社の従業員の数だけ呼び出すこと' do
        subject
        expect(ProjectMailer).to have_received(:applied).exactly(3).times
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyPublicNewProjectsService do
  let(:from) { eval(Settings.span.notify_project_created.first_from) }
  let(:to) { eval(Settings.span.notify_project_created.first_to) }
  let!(:orderer) { create(:orderer) }
  let(:corporation) { orderer.current_corporation }

  describe '#initialize' do
    let(:profession_id1) { ProfessionCategory.find(1).professions.first.id }
    let(:profession_id2) { ProfessionCategory.find(2).professions.first.id }
    let(:profession_id3) { ProfessionCategory.find(3).professions.first.id }
    let(:profession_id4) { ProfessionCategory.find(4).professions.first.id }
    let!(:project1) { create(:project, corporation: corporation, profession_ids: [profession_id1], application_open_at: from.ago(1.minute)) }
    let!(:project2) { create(:project, corporation: corporation, profession_ids: [profession_id1], application_open_at: from.since(1.minute)) }
    let!(:project3) { create(:project, corporation: corporation, profession_ids: [profession_id1], application_open_at: to.ago(1.minute)) }
    let!(:project4) { create(:project, corporation: corporation, profession_ids: [profession_id1], application_open_at: to.since(1.minute)) }
    let!(:project5) { create(:project, corporation: corporation, profession_ids: [profession_id1], application_open_at: to.ago(1.minute), is_private: true) }
    let!(:project6) { create(:project, corporation: corporation, profession_ids: [profession_id2], application_open_at: to.ago(1.minute)) }
    let!(:project7) { create(:project, corporation: corporation, profession_ids: [profession_id3], application_open_at: to.ago(1.minute)) }
    let!(:pro1) { create(:pro, profession_id: profession_id1) }
    let!(:pro2) { create(:pro, profession_id: profession_id2) }
    let!(:pro3) { create(:pro, profession_id: profession_id2) }
    let!(:pro4) { create(:pro, profession_id: profession_id4) }
    before do
      create(:pro_profession, pro_info: pro3.pro_info, profession_id: profession_id1)
    end
    subject { described_class.new(from: from, to: to) }

    it 'mail_listを初期化' do
      expect(subject.mail_list.keys).to match_array [pro1.id, pro2.id, pro3.id]
      expect(subject.mail_list[pro1.id]).to match_array [project2.id, project3.id]
      expect(subject.mail_list[pro2.id]).to match_array [project6.id]
      expect(subject.mail_list[pro3.id]).to match_array [project2.id, project3.id, project6.id]
    end
  end
  describe '#call' do
    let!(:pro1) { create(:pro) }
    let!(:pro2) { create(:pro) }
    let!(:pro3) { create(:pro) }
    let!(:pro4) { create(:pro) }
    let!(:project1) { create(:project, corporation: corporation) }
    let!(:project2) { create(:project, corporation: corporation) }
    let!(:project3) { create(:project, corporation: corporation) }
    let!(:mail_list) { {} }
    before do
      # NOTE: pro4は通知スイッチをオフに
      pro4.pro_info.update(is_new_project_notice_on: false)
      # mail_listの中身
      mail_list[pro1.id] = [project1.id]
      mail_list[pro2.id] = [project1.id, project3.id]
      mail_list[pro3.id] = [project2.id, project3.id]
      mail_list[pro4.id] = [project2.id, project3.id]
      allow_any_instance_of(NotifyPublicNewProjectsService).to receive(:mail_list).and_return mail_list
      allow(ProjectMailer).to receive_message_chain(:new_arrival, :deliver_later)
    end
    subject { described_class.new(from: from, to: to).call }

    it 'ProjectNotifiedProが必要数作成されること' do
      # NOTE: pro1で１つ、pro2、pro3で２つづつで計５つ
      expect { subject }.to change { ProjectNotifiedPro.count }.by 5
    end
    it '必要数案件通知メールが送信されること' do
      # NOTE: pro4はメールは結果としては送られないが、ProjectMailer.public_projects_not_yet_appliedの呼び出しは発生するため
      subject
      expect(ProjectMailer).to have_received(:new_arrival).exactly(4).times
    end
  end
end

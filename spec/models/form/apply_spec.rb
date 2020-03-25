# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::Apply, type: :form_model do
  describe 'validation' do
    let!(:current_user) { create(:pro) }
    let!(:orderer) { create(:orderer) }
    let!(:project) { create(:project, corporation: orderer.current_corporation) }

    # 正常パラメーター
    let(:pro_id) { current_user.id }
    let(:project_id) { project.id }
    let(:content) { 'メッセージ内容' }

    subject { Form::Apply.new(pro_id: pro_id, project_id: project_id, content: content) }

    describe '全て正常パラメーター' do
      it '有効なこと' do
        is_expected.to be_valid
      end
    end
    describe 'pro_id' do
      context '空欄' do
        let(:pro_id) { 0 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '無効な場合' do
        let(:pro_id) { 999999 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
    describe 'project_id' do
      context '空欄' do
        let(:project_id) { 0 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '無効な場合' do
        let(:project_id) { 999999 }
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
    end
    describe 'contentが空欄の時' do
      let(:content) { '' }

      it '無効なこと' do
        is_expected.to be_invalid
      end
    end
  end
end

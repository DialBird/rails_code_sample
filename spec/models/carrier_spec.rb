# frozen_string_literal: true

# == Schema Information
#
# Table name: carriers # 職歴
#
#  id          :bigint(8)        not null, primary key
#  detail      :text             default(""), not null    # 業務内容
#  end_month   :integer                                   # 終了月
#  end_year    :integer                                   # 終了年
#  is_employed :boolean          default(FALSE), not null # 在職中フラグ
#  start_month :integer                                   # 開始月
#  start_year  :integer                                   # 開始年
#  title       :string           default(""), not null    # 会社名・プロジェクト名
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pro_info_id :bigint(8)
#
# Indexes
#
#  index_carriers_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

require 'rails_helper'

RSpec.describe Carrier, type: :model do
  describe 'validation' do
    describe 'title' do
      subject { build(:carrier) }
      it_behaves_like 'invalid value', :title, ''
    end

    describe '開始年と月' do
      subject { build(:carrier, start_year: year, start_month: month) }

      context 'どちらかが欠けていた場合' do
        let(:year) { nil }
        let(:month) { 5 }
        it '無効であること' do
          is_expected.to be_invalid
          expect(subject.errors.full_messages).to match_array ['開始年と月を両方入力してください']
        end
      end
      context '両方存在する場合' do
        let(:year) { 1991 }
        let(:month) { 5 }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
      context '両方存在しない場合' do
        let(:year) { nil }
        let(:month) { nil }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
    end
    describe '終了年と月' do
      subject { build(:carrier, end_year: year, end_month: month) }

      context 'どちらかが欠けていた場合' do
        let(:year) { nil }
        let(:month) { 5 }
        it '無効であること' do
          is_expected.to be_invalid
          expect(subject.errors.full_messages).to match_array ['終了年と月を両方入力してください']
        end
      end
      context '両方存在する場合' do
        let(:year) { 1991 }
        let(:month) { 5 }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
      context '両方存在しない場合' do
        let(:year) { nil }
        let(:month) { nil }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
    end
    describe '開始と終了' do
      subject { build(:carrier, start_year: 1990, start_month: 1, end_year: year, end_month: month) }

      context '開始よりも終了が後の場合' do
        let(:year) { 1990 }
        let(:month) { 2 }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
      context '開始と終了が同じ場合' do
        let(:year) { 1990 }
        let(:month) { 1 }
        it '有効であること' do
          is_expected.to be_valid
        end
      end
      context '開始よりも終了が先の場合' do
        let(:year) { 1989 }
        let(:month) { 12 }
        it '無効であること' do
          is_expected.to be_invalid
          expect(subject.errors.full_messages).to match_array ['開始年月と終了年月を正しく入力してください']
        end
      end
    end
  end
end

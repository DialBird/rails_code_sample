# frozen_string_literal: true

# == Schema Information
#
# Table name: corporations
#
#  id                :bigint(8)        not null, primary key
#  address           :string
#  corporation_image :string
#  cover_image       :string
#  department        :string           default(""), not null
#  detail            :text
#  established_at    :date
#  facebook_url      :string
#  instagram_url     :string
#  is_freelance      :boolean          default(FALSE), not null
#  is_no_department  :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  number_of_workers :integer                                   # 従業員数（SOKUDAN内のデータには依存しない）
#  phone             :string           default(""), not null
#  state             :string           default(""), not null
#  twitter_url       :string
#  url               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :bigint(8)
#
# Indexes
#
#  index_corporations_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#

require 'rails_helper'

RSpec.describe Corporation, type: :model do
  let!(:orderer) { create(:orderer) }
  describe 'validation' do
    subject { build(:corporation, created_by: orderer) }
    describe 'name' do
      context '会社名が未入力でフリーランスチェックが入っていない場合' do
        before do
          subject.name = ''
          subject.is_freelance = false
        end
        it '無効なこと' do
          is_expected.to be_invalid
        end
      end
      context '会社名が未入力でフリーランスチェックが入っている場合' do
        before do
          subject.name = ''
          subject.is_freelance = true
        end
        it '有効なこと' do
          is_expected.to be_valid
        end
      end
      context '会社名が入力されていて、フリーランスチェックが入っていない場合' do
        before do
          subject.name = '会社名'
          subject.is_freelance = false
        end
        it '有効なこと' do
          is_expected.to be_valid
        end
      end
    end
  end
  describe 'before_validation' do
    describe 'url' do
      let(:corporation) { create(:corporation, created_by: orderer, url: url) }
      subject { corporation.save }

      context '空欄で保存した場合' do
        let(:url) { '' }
        it '空欄のまま保存すること' do
          subject
          expect(corporation.url).to eq ''
        end
      end
      context 'http://で保存した場合' do
        let(:url) { 'http://example.com' }
        it 'そのまま保存すること' do
          subject
          expect(corporation.url).to eq url
        end
      end
      context 'https://で保存した場合' do
        let(:url) { 'https://example.com' }
        it 'そのまま保存すること' do
          subject
          expect(corporation.url).to eq url
        end
      end
      context 'プロトコル無しで保存した場合' do
        let(:url) { 'example.com' }
        it 'http://をつけて保存すること' do
          subject
          expect(corporation.url).to eq 'http://' + url
        end
      end
    end
  end
end

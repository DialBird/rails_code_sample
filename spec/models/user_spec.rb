# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint(8)        not null, primary key
#  birth_year                 :integer          default(0), not null    # 誕生年
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  cover_image                :string                                   # カバー写真
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  deregistered_at            :datetime
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null   # 名
#  first_name_kana            :string           default(""), not null   # 名（フリガナ）
#  is_apply_notice_on         :boolean          default(TRUE), not null
#  is_message_notice_on       :boolean          default(TRUE), not null
#  is_new_pro_notice_on       :boolean          default(TRUE), not null
#  is_news_notice_on          :boolean          default(TRUE), not null
#  is_project_liked_notice_on :boolean          default(TRUE), not null
#  last_name                  :string           default(""), not null   # 姓
#  last_name_kana             :string           default(""), not null   # 姓（フリガナ）
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  profile_image              :string                                   # プロファイル写真
#  receive_likes_count        :integer          default(0), not null    # いいねのカウントカラム
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#  state                      :string           default(""), not null   # ステータス
#  unconfirmed_email          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  current_corporation_id     :bigint(8)
#  prefecture_id              :integer          default(0), not null    # 都道府県（prefecture.yml参照）
#  usage_type_id              :integer          default(0), not null    # 主な用途（usage_type.yml参照）
#
# Indexes
#
#  index_users_on_confirmation_token      (confirmation_token) UNIQUE
#  index_users_on_current_corporation_id  (current_corporation_id)
#  index_users_on_current_sign_in_at      (current_sign_in_at)
#  index_users_on_email                   (email) UNIQUE
#  index_users_on_reset_password_token    (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (current_corporation_id => corporations.id)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    subject { build(:user, usage_type_id: User::UsageType::ACCEPTING.id) }
    describe 'デフォルト' do
      it '有効なこと' do
        is_expected.to be_valid
      end
    end
    describe 'email' do
      it_behaves_like 'invalid value', :email, nil
    end
    describe 'password' do
      it_behaves_like 'invalid value', :password, nil
      it_behaves_like 'invalid value', :password, 'password', title: '半角英字だけの8文字以上だと無効であること'
      it_behaves_like 'invalid value', :password, 'passwo1', title: '半角英数混ざった8文字以下だと無効であること'
      it_behaves_like 'valid value', :password, 'password1', title: '半角英数混ざった8文字以上だと有効であること'
    end
    describe 'state' do
      User.aasm.states.map(&:name).each do |s|
        it_behaves_like 'valid value', :state, s
      end
      it_behaves_like 'invalid value', :state, ''
    end
    describe '更新時且つパスワード変更時以外' do
      before { subject.save }
      %w[last_name first_name prefecture_id usage_type_id].each do |field|
        describe field do
          context "#{field}が空欄の場合" do
            it '無効なこと' do
              subject.send("#{field}=", '')
              is_expected.to be_invalid
            end
          end
        end
      end
    end
    describe 'birth_year' do
      it_behaves_like 'valid value', :birth_year, 0, title: '未選択は有効であること'
      it_behaves_like 'invalid value', :birth_year, Date.today.year, title: '今年は設定できないこと'
      it_behaves_like 'invalid value', :birth_year, Date.today.year + rand(1..10), title: '来年以降は設定できないこと'
    end
  end

  describe '#from_omniauth' do
    let(:rand_num) { rand(9) }
    let(:uid) { "123456#{rand_num}" }
    let(:provider) { Settings.provider.facebook }
    let(:email) { "test#{rand_num}@example.com" }
    let(:token) { '12345' }
    let(:auth) do
      Hashie::Mash.new(uid: uid,
                       provider: provider,
                       info: { last_name: '姓',
                               first_name: '名',
                               email: email },
                       credentials: { token: token })
    end
    subject { User.from_omniauth(auth) }

    it '新規ユーザーが作られること' do
      expect { subject }.to change { User.count }.by 1
    end
    context 'authにEmailが入っていなかった場合' do
      before { auth.info.delete(:email) }
      it 'ダミーのEmailで新規ユーザーが作られること' do
        expect { subject }.to change { User.count }.by 1
        expect(User.last.email).to eq "#{User::TEMP_EMAIL_PREFIX}-#{uid}-#{provider}.com"
      end
    end
  end
end

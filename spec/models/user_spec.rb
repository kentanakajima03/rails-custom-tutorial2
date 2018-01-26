require 'rails_helper'

RSpec.describe User, type: :model do
  context 'when invalid name contains' do
    it 'should be non-empty name' do
      user = build(:user, name: ' ')
      expect(user).not_to be_valid
    end

    it 'should not be long name' do
      user = build(:user, name: 'a' * 51)
      expect(user).not_to be_valid
    end
  end

  context 'when the invalid email contains' do
    it 'should be non-empty email' do
      user = build(:user, email: ' ')
      expect(user).not_to be_valid
    end

    it 'should not be long email' do
      suffix = '@example.com'
      user = build(:user, email: 'a' * (256 - suffix.length) + suffix)
      expect(user).not_to be_valid
    end

    it 'should be email-formatted' do
      %w[user@example,com
         user_at_foo.org
         user.name@example.foo@bar_baz.com
         foo@bar+baz.com].each do |address|
        user = build(:user, email: address)
        expect(user).not_to be_valid
      end
    end

    it 'should be unique email' do
      create(:user)
      duplicated_user = build(:user)
      expect(duplicated_user).not_to be_valid
    end
  end

  context 'when the invalid password contains' do
    it 'should be present(nonblank) password' do
      user = build(:user, password: ' ' * 6)
      expect(user).not_to be_valid
    end

    it 'should be at least 6 characters' do
      invalid_password = 'a' * 5
      user = build(:user, password: invalid_password, password_confirmation: 5)
      expect(user).not_to be_valid
    end
  end

  context 'when the valid email contains' do
    it 'should be email-formatted' do
      %w[user@example.com
         USER@foo.COM
         A_US-ER@foo.bar.org
         first.last@foo.jp
         alice+bob@baz.cn].each do |address|
        user = build(:user, email: address)
        expect(user).to be_valid
      end
    end
  end

  context 'when callbacks' do
    let(:user) { create(:user) }
    it 'calls downcase_email before_save' do
      expect(user).to callback(:downcase_email).before(:save)
    end
  end

  context 'when public method calls' do
    include UsersHelper
    it 'tests remember method' do
      user = build(:user)
      user.remember
      expect(user.remember_token).to be
      expect(BCrypt::Password.new(user.remember_digest)).to eq user.remember_token
    end

    describe 'tests authenticated? method' do
      it 'fails when not remembered' do
        user = build(:user)
        expect(user.authenticated?(nil)).to be_falsy
      end

      it 'fails when puts invalid remember_token' do
        user = build(:user)
        user.remember
        expect(user.authenticated?('')).to be_falsy
      end

      it 'succeed when remember_digest' do
        user = build(:user)
        user.remember

        expect(user.authenticated?(user.remember_token)).to be_truthy
      end
    end
  end
  context 'when private method calls' do
    it 'downcases email' do
      user = build(:user, email: 'Foo@ExAmPLe.COm')
      user.send(:downcase_email)
      expect(user.email).to eq 'foo@example.com'
    end
  end
end

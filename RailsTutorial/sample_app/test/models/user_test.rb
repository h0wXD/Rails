require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'foobar@example.com', password: 'foobar', password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?, 'user should be valid'
  end

  test 'name should be present' do
    @user.name = '    '
    assert_not @user.valid?, 'name not present should be invalid'
  end

  test 'email should be present' do
    @user.email = '    '
    assert_not @user.valid?, 'email not present should be invalid'
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?, 'name length should be invalid'
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?, 'email length should be invalid'
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should not accept invalid addresses' do
    invalid_addresses = %w[user@example..com USER@.test.COM]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?, 'email address is not unique'
  end

  test 'email address should be saved as lower-case' do
    mixed_case_email = "FoO@bArExAmPle.com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?, 'password length is too short'
  end
end

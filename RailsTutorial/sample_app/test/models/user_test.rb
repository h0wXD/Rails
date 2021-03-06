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

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
    end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    user = users(:one)
    another_user  = users(:two)
    assert_not user.following?(another_user)
    user.follow(another_user)
    assert user.following?(another_user)
    assert another_user.followers.include?(user)
    user.unfollow(another_user)
    assert_not user.following?(another_user)
  end

  test 'feed should have the right posts' do
    one = users(:one)
    two  = users(:two)
    three  = users(:three)
    # Posts from followed user
    three.microposts.each do |post_following|
      assert one.feed.include?(post_following)
    end
    # Posts from self
    one.microposts.each do |post_self|
      assert one.feed.include?(post_self)
    end
    # Posts from unfollowed user
    two.microposts.each do |post_unfollowed|
      assert_not one.feed.include?(post_unfollowed)
    end
  end
end

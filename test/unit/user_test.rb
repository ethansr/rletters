require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Test validation: require identifier, name and e-mail
  test "should not save empty user" do
    user = User.new
    assert !user.save, 'Saved an empty user'
  end
  
  test "should not save without identifier" do
    user = User.new
    user.name = 'John Doe'
    user.email = 'bob@bob.com'
    assert !user.save, 'Saved a user without identifier set'
  end
  
  test "should not save without name" do
    user = User.new
    user.email = 'bob@bob.com'
    user.identifier = 'https://google.com'
    assert !user.save, 'Saved a user without name set'
  end
  
  test "should not save without email" do
    user = User.new
    user.name = 'John Doe'
    user.identifier = 'https://google.com'
    assert !user.save, 'Saved a user without email set'
  end

  # Validations on email field: no duplicates, valid emails
  test "should not save duplicate email" do
    user = User.new
    user.name = 'Email Test User'
    user.identifier = 'https://google.com/notduplicate'
    user.email = 'jdoe@gmail.com'
    assert !user.save, 'Saved a user with a duplicate email'
  end

  test "should not save bad email" do
    user = User.new
    user.name = 'Email Test User'
    user.identifier = 'https://google.com/notduplicate'
    user.email = 'asdf-not-an-email.com'
    assert !user.save, 'Saved a user with a clearly invalid email'
  end

end

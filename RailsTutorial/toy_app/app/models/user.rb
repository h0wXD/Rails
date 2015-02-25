class User < ActiveRecord::Base
  has_many :microposts
  validates(:name, presence: true, length: {maximum: 40})
  validates(:email, presence: true, length: {maximum: 60})
end

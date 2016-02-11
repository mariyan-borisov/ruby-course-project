require 'bcrypt'
require 'sinatra/activerecord'

class User < ActiveRecord::Base
  USER_VALID_EXPRESSION = /\A[a-zA-Z0-9_-]+\Z/

  validates_uniqueness_of :user_name
  validates_presence_of :user_name
  validates_format_of :user_name, with: USER_VALID_EXPRESSION

  has_many :articles

  def self.user_name_valid?(user_name)
    !user_name.nil? and !user_name.match(USER_VALID_EXPRESSION).nil?
  end

  def self.user_name_taken?(user_name)
    !find_by_user_name(user_name).nil?
  end

  def self.register(user_name, password, is_admin = false)
    user = new
    user.user_name = user_name
    user.password_hash = BCrypt::Password.create(password)
    user.time = Time.now
    user.is_admin = is_admin
    user.save
  end
end

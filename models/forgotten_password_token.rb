require 'sinatra/activerecord'

class ForgottenPasswordToken < ActiveRecord::Base
  belongs_to :user
end

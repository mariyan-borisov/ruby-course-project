require 'sinatra'
require 'sinatra/activerecord'
require 'tilt/haml'
require './app/models/user_model'

enable :sessions

get '/' do
  haml :index
end

get '/registration/' do
  haml :registration
end

post '/registration/' do
  @errors = []
  if !User.user_name_valid?(params[:user_name])
    @errors << 'User name is not valid'
  end
  if User.user_name_taken?(params[:user_name])
    @errors << 'That user name already exists'
  end
  if params[:first_password].length < 6
    @errors << 'The password has to be at least 6 characters long'
  end
  if params[:first_password] != params[:second_password]
    @errors << "Passwords don't match"
  end

  return haml :registration unless @errors.empty?

  is_admin = false
  if User.all.empty?
    is_admin = true
  end

  User.register(params[:user_name], params[:first_password], is_admin)

  redirect to('/users/')
end

get '/users/' do
  @users = User.all.to_a
  haml :users
end

get '/users/:user_id' do
  "UID: #{params[:user_id]}"
end

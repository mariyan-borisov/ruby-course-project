require 'sinatra'
require 'sinatra/activerecord'
require 'tilt/haml'
require './app/models/user_model'
require './app/models/article_model'
require './app/models/category_model'

enable :sessions

get '/' do
  haml :index
end

get '/categories/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])
  unless user.is_admin
    return "Get off 'muh lawn..."
  end

  @categories = Category.all.to_a

  haml :categories
end

post '/categories/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])
  unless user.is_admin
    return "Get off 'muh lawn..."
  end

  Category.create({name: params[:name]})

  @categories = Category.all.to_a

  haml :categories
end

post '/delete_category/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])
  unless user.is_admin
    return "Get off 'muh lawn..."
  end

  begin
    category = Category.find(params[:category])
    category.destroy
    redirect to('/categories/')
  rescue
    'No such category'
  end
end

get '/create_article/' do
  @categories = Category.all.to_a
  haml :create_article
end

post '/create_article/' do

end

get '/article/:article_id' do
  begin
    @article = Article.find(params[:article_id])
  rescue
    @article = nil
  end
  haml :article
end

get '/logout/' do
  session.delete :user_name
  redirect to('/')
end

get '/login/' do
  unless session[:user_name].nil?
    return redirect to('/')
  end
  haml :login
end

post '/login/' do
  unless session[:user_name].nil?
    return redirect to('/')
  end

  user = User.find_by_user_name(params[:user_name])

  if user.nil?
    @error = "No such user..."
    return haml :login
  end

  if BCrypt::Password.new(user.password_hash) != params[:password]
    @error = "Wrong password..."
    haml :login
  else
    session[:user_name] = user.user_name
    redirect to('/')
  end
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

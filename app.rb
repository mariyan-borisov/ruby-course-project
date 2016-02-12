require 'sinatra'
require 'sinatra/activerecord'
require 'tilt/haml'
require 'rack/utils'
require 'maruku'
require_relative 'models/user'
require_relative 'models/article'
require_relative 'models/category'

enable :sessions

get '/' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end

  @categories = Category.all.to_a
  @articles = Article.all.to_a

  haml :index
end

get '/search/' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end
  @categories = Category.all.to_a

  @query = params[:query]
  @category = params[:category]

  if params[:category] == "all"
    @articles = Article.where(
      "title LIKE ? OR content LIKE ?",
      "%#{@query}%",
      "%#{@query}%",
    ).to_a
  else
    @articles = Article.where(
      "(title LIKE ? OR content LIKE ?) AND category_id = ?",
      "%#{@query}%",
      "%#{@query}%",
      @category
    ).to_a
  end

  haml :search
end

post '/toggle_rank/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])
  unless user.is_admin
    return "Get off 'muh lawn..."
  end

  user = User.find(params[:user])
  user.update({is_admin: !user.is_admin})

  redirect to("/user/#{user.user_name}")
end

get '/categories/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  @user = User.find_by_user_name(session[:user_name])
  unless @user.is_admin
    return "Get off 'muh lawn..."
  end

  @categories = Category.all.to_a

  haml :categories
end

post '/categories/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  @user = User.find_by_user_name(session[:user_name])
  unless @user.is_admin
    return "Get off 'muh lawn..."
  end

  Category.create({name: Rack::Utils.escape_html(params[:name])})

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
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end
  @categories = Category.all.to_a

  haml :create_article
end

post '/create_article/' do
  if session[:user_name].nil?
    "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])

  Article.create({
    title: Rack::Utils.escape_html(params[:title]),
    content: Rack::Utils.escape_html(params[:content]),
    time: Time.now,
    category_id: params[:category],
    user_id: user.id
  })

  redirect to('/')
end

get '/article/:article_id' do
  begin
    @article = Article.find(params[:article_id])
  rescue
    @article = nil
  end

  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end
  @categories = Category.all.to_a

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

  @categories = Category.all.to_a

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
  @categories = Category.all.to_a

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

  redirect to('/')
end

get '/users/' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end
  @categories = Category.all.to_a

  @users = User.all.to_a

  haml :users
end

get '/user/:user_name' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end

  @categories = Category.all.to_a
  @viewed_user = User.find_by_user_name(params[:user_name])
  @articles = Article.where({user_id: @viewed_user.id}).all.to_a

  haml :user
end

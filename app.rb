require 'sinatra'
require 'sinatra/activerecord'
require 'tilt/haml'
require 'rack/utils'
require 'maruku'
require 'uuidtools'
require 'pony'

enable :sessions

require_relative 'models/user'
require_relative 'models/article'
require_relative 'models/category'
require_relative 'models/comment'
require_relative 'models/forgotten_password_token'

require_relative 'routes/users'
require_relative 'routes/articles'
require_relative 'routes/categories'
require_relative 'routes/comments'

get '/' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end

  @categories = Category.all.to_a
  @articles = Article.order(time: :desc).to_a

  haml :index
end

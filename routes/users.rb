get '/recover/:token' do
  @token_parameter = params[:token]
  token = ForgottenPasswordToken.find_by_token(@token_parameter)
  if token.nil?
    return 'No such token'
  end

  haml :recover
end

post '/recover/' do
  token = ForgottenPasswordToken.find_by_token(params[:token])
  if token.nil?
    return 'No such token'
  end

  token.user.update({password_hash: BCrypt::Password.create(params[:password])})

  token.destroy

  'The password was changed...'
end

get '/forgotten_password/' do
  haml :forgotten_password
end

post '/forgotten_password/' do
  user = User.find_by_email(params[:email])
  if user.nil?
    return 'No such user'
  end
  
  token = ForgottenPasswordToken.new
  token.user = user
  token.token = UUIDTools::UUID.random_create.to_s
  token.save

  Pony.mail(to: user.email, from: 'ruby-course-project@abv.bg', subject: 'Password recovery')

  'Token was sent to your email...'
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
  @categories = Category.all.to_a
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
  @categories = Category.all.to_a

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
  if params[:email].match(/^[^@]+@[^.]+\.[a-z]+$/).nil?
    @errors << "Invalid email"
  end

  return haml :registration unless @errors.empty?

  is_admin = false
  if User.all.empty?
    is_admin = true
  end

  User.register(params[:user_name], params[:email], params[:first_password], is_admin)

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
  @articles = Article.where({user_id: @viewed_user.id}).order(time: :desc).to_a

  haml :user
end

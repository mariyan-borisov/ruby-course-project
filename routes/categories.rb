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

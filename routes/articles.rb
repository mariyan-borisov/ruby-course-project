get '/search/' do
  unless session[:user_name].nil?
    @user = User.find_by_user_name(session[:user_name])
  end
  @categories = Category.all.to_a

  @query = Rack::Utils.escape_html(params[:query])
  @category = params[:category]

  if params[:category] == "all"
    @articles = Article.where(
      "title LIKE ? OR content LIKE ?",
      "%#{@query}%",
      "%#{@query}%",
    ).order(time: :desc).to_a
  else
    @articles = Article.where(
      "(title LIKE ? OR content LIKE ?) AND category_id = ?",
      "%#{@query}%",
      "%#{@query}%",
      @category
    ).order(time: :desc).to_a
  end

  haml :search
end

post '/delete_article/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])

  begin
    article = Article.find(params[:article])
  rescue
    return "This article doesn't exist..."
  end

  if user.id != article.user_id or !user.is_admin
    return "Get off 'muh lawn..."
  end

  article.destroy

  redirect to('/')
end

get '/edit_article/:article_id' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  @user = User.find_by_user_name(session[:user_name])

  @article = Article.find(params[:article_id])

  if @user.id != @article.user_id
    return "Get off 'muh lawn..."
  end

  @categories = Category.all.to_a

  haml :edit_article
end

post '/edit_article/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])

  article = Article.find(params[:article_id])

  if user.id != article.user_id
    return "Get off 'muh lawn..."
  end

  article.update({
    title: Rack::Utils.escape_html(params[:title]),
    content: Rack::Utils.escape_html(params[:content]),
    category_id: params[:category]
  })

  redirect to("/article/#{article.id.to_s}")
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
  @comments = Comment.where({article_id: @article.id}).order(time: :desc).to_a

  haml :article
end

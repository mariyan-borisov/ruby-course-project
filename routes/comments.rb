post '/post_comment/' do
  if session[:user_name].nil?
    return "Get off 'muh lawn..."
  end

  user = User.find_by_user_name(session[:user_name])

  if params[:content] != nil and params[:content] != ""
    Comment.create({
      content: Rack::Utils.escape_html(params[:content]),
      time: Time.now,
      article_id: params[:article_id],
      user_id: user.id
    })
  end

  redirect to("/article/#{params[:article_id]}")
end

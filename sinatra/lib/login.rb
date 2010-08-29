helpers do
  def logged_in?
   session[:openid] && session[:openid].status == :success 
  end

  def require_user
    # then we are logged in
    unless logged_in?
      store_location
      redirect '/login'
      return false
    end
  end

  def store_location
    # may only need path...
    session[:return_to] = request.url
  end
  
  def redirect_back_or_default(default)
    redirect(session[:return_to] || default)
    session[:return_to] = nil
  end
end

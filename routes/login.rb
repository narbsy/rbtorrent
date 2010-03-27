require 'rack/openid'

# Session needs to be before Rack::OpenID
use Rack::Session::Cookie
use Rack::OpenID

get '/login' do
  haml :login
end

# Created from the rack-openid readme (well, the hard parts were)
post '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success && User.get(resp.identity_url)
      session[:openid] = request.env["rack.openid.response"]
      redirect '/'
    else
      # errors stored in:
      # session[:openid].message on failure
      session[:openid] = nil
      redirect '/login'
    end
  else
    # forward to openid upon form submission
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => params["openid_identifier"]
    )
    halt 401, 'got openid?'
  end
end

get '/logout' do
  # zero everything out and start afresh
  session.clear
  redirect '/'
end


%w{ rubygems sinatra haml sass dm-core yaml }.each { |lib| require lib }

#Useful things
Dir["lib/*.rb"].each { |lib| require lib }

#Load routes in other files
Dir["routes/*.rb"].each { |route| load route }

setup_download_dir

get '/' do
  @rtorrent = Rtorrent.new
  @list = @rtorrent.list "default", "d.get_hash=", "d.get_name=", "d.get_state="

  haml :index
end

get '/add' do
  haml :add
end

post '/add' do
  contents = read_remote_file(params[:url]) 
  return haml(:add) unless contents

  @rtorrent = Rtorrent.new

  name = write_local_file contents
  unless name
    return haml :add
  end

  # Really, the only way for this to fail is for the call itself to not go
  # through.
  if @rtorrent.load name, params[:start]
    params[:messages] = "Successfully added torrent!"
  end

  haml :add
end

[:stop, :erase, :start].each do |route|
  post '/' + route do
    @rtorrent = Rtorrent.new
    @rtorrent.send route, params[:hash]
  end
end

#for sass generated css
get '/main.css' do
	headers 'Content-Type' => 'text/css; charset=utf-8'
	sass :main
end



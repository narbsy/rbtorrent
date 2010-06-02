%w{ rubygems sinatra haml sass dm-core yaml sinatra/content_for json }.each { |lib| require lib }

#Useful things
Dir["lib/*.rb"].each { |lib| require lib }

#Load routes in other files
Dir["routes/*.rb"].each { |route| load route }

setup_download_dir!
# Make sure we set the correct mime_type for Chrome
mime_type :js, "text/javascript"

before do
  unless ['/login', '/main.css'].include?(request.path) || request.path.end_with?("js")
    require_user
  end
end

get '/' do
  @list = Rtorrent::Torrent.all

  haml :index
end

get '/add' do
  haml :add
end

post '/add' do
  contents = read_remote_file(params[:url]) 
  return haml(:add) unless contents

  @rtorrent = Rtorrent.new

  name = write_local_file! contents
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

# note, i should change this to 'put' probably.
[:stop, :erase, :start].each do |route|
  post '/' + route do
    torrent = Rtorrent::Torrent.get params[:hash]
    torrent.send route
    # set headers

    content_type :json
    {status: torrent.get_status(true)}.to_json
  end
end


# TODO: figure out how to send new torrents over to the web front end via ajax
get '/update' do
  # Get only the properties we care about for the torrent updates
  list = Rtorrent::Torrent.all :properties => [ :get_hash, :get_state, :get_ratio, 
                                                :get_complete, :is_open, :get_size_chunks, 
                                                :get_completed_chunks, :get_down_rate, 
                                                :get_up_rate ]

  content_type :json 
  list.map do |torrent|
    h = {}
    [:hash, :status, :ratio, :down_rate, :up_rate].each do |property|
      h[property] = torrent.send "get_#{property}"
    end
    h[:percentage] = torrent.percentage
    h
  end.to_json
end

#for sass generated css
get '/main.css' do
	headers 'Content-Type' => 'text/css; charset=utf-8'
	sass :main
end



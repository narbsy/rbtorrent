%w{ rubygems sinatra haml sass dm-core yaml sinatra/content_for json }.each { |lib| require lib }

#Useful things
Dir["lib/*.rb"].each { |lib| require lib }

#Load routes in other files
Dir["routes/*.rb"].each { |route| load route }

setup_download_dir!

before do
  require_user unless request.path == '/login' || request.path == '/main.css'
end

get '/' do
  @rtorrent = Rtorrent.new
  @list = @rtorrent.list "default", "d.get_hash=", "d.get_name=", "d.get_state=", "d.get_ratio=", "d.get_complete=", "d.is_open=", "d.get_size_chunks=", "d.get_completed_chunks="

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

# note, i should change this to put probably.
[:stop, :erase, :start].each do |route|
  post '/' + route do
    torrent = Rtorrent.new.from_hash(params[:hash])
    torrent.send route
    # set headers
    content_type :json
    {status: torrent.get_status(true)}.to_json
  end
end

get '/update' do
  @rtorrent = Rtorrent.new
  @list = @rtorrent.list "default", "d.get_hash=", "d.get_name=", "d.get_state=", "d.get_ratio=", "d.get_complete=", "d.is_open=", "d.get_size_chunks=", "d.get_completed_chunks="

  # We're really interested in updating: ratio, percentage & status, so we need to update a couple of properties.
  list = @rtorrent.list "default", "d.get_hash=", "d.get_state=", "d.get_ratio=", "d.get_complete=", "d.is_open=", "d.get_size_chunks=", "d.get_completed_chunks="

  content_type :json 
  list.map do |torrent|
    h = {}
    [:hash, :status, :ratio].each do |property|
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



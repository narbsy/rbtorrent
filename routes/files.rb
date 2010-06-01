get '/files/:hash' do
  @torrent = Rtorrent::Torrent.get params[:hash]

  haml :files, :layout => false
end

post '/files/:hash' do
  torrent = Rtorrent::Torrent.get params[:hash]
  torrent.set_file_priorities params

  redirect '/'
end

delete '/files/:hash/:index' do
  puts params
  torrent = Rtorrent::Torrent.get params[:hash]
  file = torrent.file params[:index]
  puts file.name
  
  if file.delete_physical_copy
    status 200
  else
    status 400
  end
  # We really only care about sending the status.
  ""
end

class TorrentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
    @download_dir = ConfigOption.get "download-dir"
    
    @torrents = Torrent.all(@connection)
  end
end

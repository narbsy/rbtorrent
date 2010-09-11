class TorrentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :create_connection

  def index
    @download_dir = ConfigOption.get "download-dir"
    
    @torrents = Torrent.all @connection
  end

  [ :start, :stop, :erase ].each do |action|
    define_method action do
      @torrent = Torrent.find @connection, params[:id]
      @torrent.send action

      render :partial => 'update'
    end
  end

  private
  def create_connection
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
  end
end

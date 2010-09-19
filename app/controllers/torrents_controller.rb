class TorrentsController < ApplicationController
  include RemoteFiles
  before_filter :authenticate_user!
  before_filter :create_connection

  def index
    @download_dir = ConfigOption.get "download-dir"
    
    @torrents = Torrent.all @connection
  end

  def new
  end

  def create
    url = params[:torrent][:url]
    start = params[:torrent][:start] == "0"

    contents, name = nil
    [
      [ lambda { contents = read_remote_file(url) }, "Could not read remote url!" ],
      [ lambda { name = write_local_file!(torrent_dir, contents) }, "Could not write local file!" ] 
    ].each do |f, error_message|
      unless f.call
        flash.alert = error_message
        render :action => :new
        return
      end
    end

    logger.debug "Here in the child..."

    @rtorrent = Rtorrent.new @connection

    logger.info "name,contents= #{[name,contents].inspect}"

    if @rtorrent.load torrent_dir, name, start
      flash.notice = "Successfully added torrent!"
    end

    render :action => :new
  end

  [ :start, :stop, :erase ].each do |action|
    define_method action do
      @torrent = Torrent.find @connection, params[:id]
      @torrent.send action

      render :partial => 'update'
    end
  end

  def check
    @torrents = Torrent.all @connection, :properties => [ :get_hash, :get_state, :get_ratio, 
                                                          :get_complete, :is_open, :get_size_chunks, 
                                                          :get_completed_chunks, :get_down_rate, 
                                                          :get_up_rate ]
    json_torrents = @torrents.map do |torrent|
      {}.tap do |h|
        [:hash, :status, :ratio, :down_rate, :up_rate].each do |property|
          h[property] = torrent.send "get_#{property}"
        end
        h[:percentage] = torrent.percentage
      end
    end
    render :json => json_torrents
  end

  private
  def create_connection
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
  end
end

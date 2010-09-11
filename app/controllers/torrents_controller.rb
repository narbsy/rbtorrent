class TorrentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :create_connection

  def index
    @download_dir = ConfigOption.get "download-dir"
    
    @torrents = Torrent.all @connection
  end

  def new
  end

  def create
    redirect_to :action => :index
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
    render :json => json_torrents, :callback => "update_torrents"
  end

  private
  def create_connection
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
  end
end

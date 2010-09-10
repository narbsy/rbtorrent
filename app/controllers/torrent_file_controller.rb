class TorrentFileController < ApplicationController
  before_filter :create_connection
  def index
    respond_to do |format|
      format.js { render :index, :layout => false }
    end
  end

  def create
    @torrent.set_file_priorities params

    redirect_to '/'
  end

  private
  def create_connection
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
    @torrent = Torrent.find @connection, params[:torrent_id]
  end
end

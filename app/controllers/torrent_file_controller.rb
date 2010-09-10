class TorrentFileController < ApplicationController
  def index
    @host = ConfigOption.get("host")
    @connection = Connection.new @host.value
    @torrent = Torrent.find @connection, params[:torrent_id]

    puts request.xhr?
    respond_to do |format|
      format.js { render :index, :layout => false }
    end
  end

  def create
    puts "hello"
    # @torrent = Torrent.get params[:hash]
    # @torrent.set_file_priorities params

    puts torrents_url
    redirect_to '/'
  end
end

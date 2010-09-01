class TorrentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @connection = Connection.new
    
    @torrents = Torrent.all(@connection)
  end
end

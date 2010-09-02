class TorrentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @connection = Connection.new "narbsy.com"
    
    @torrents = Torrent.all(@connection)
  end
end

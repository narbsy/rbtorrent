class TorrentsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @torrents = []
  end
end

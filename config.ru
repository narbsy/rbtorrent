require 'rubygems'
require 'sinatra'

# set :environment, :production
# set :port, 4567

require 'rbtorrent'

require 'lib/response_time_injector'
use Rack::ResponseTimeInjector

run Sinatra::Application

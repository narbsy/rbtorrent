require 'rbtorrent'
require 'spec'
require 'rack/test'
require 'spec_helper'

set :environment, :test

describe 'The rbtorrent app' do
	def app
		Sinatra::Application
	end

	context "it should not die on file uploads" do
		it "should not exceptionify on bad url" do
			request '/add', :method => :post, :params => { :url => "oranges" }
			last_response.should be_ok
			# test for an error message of some sort, somehow
		end

		it "should not raise an exception on bad file path config" do
			config["torrents-dir"] = "/this/directory/does/not/exist"
			request '/add', :method => :post, :params => { :url => "http://dattebayo.com/t/b255.torrent" }
			last_response.should be_ok
			# test for an error message of some sort, somehow
		end
	end
end

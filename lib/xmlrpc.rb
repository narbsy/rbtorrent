require 'xmlrpc/client'

class Client
	def initialize(host)
		@host = host
		@client = XMLRPC::Client.new(@host)
	end

	# tragically annoying, but seems to be required as the timeout parameter does
	# not listen, and instead just forces a broken pipe after about 5 seconds.
	def call(method, *args)
		@client.call(method, *args)
	rescue Errno::EPIPE
		@client = XMLRPC::Client.new(@host)
		@client.call(method, *args)
	end
end

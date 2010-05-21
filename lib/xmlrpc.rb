require 'xmlrpc/client'

# Essentially proxy class that asks twice on failure. Makes life a lot easier.
class Client
	def initialize(host)
		@host = host
		@client = XMLRPC::Client.new(@host)
    @prefix = nil
	end

	# tragically annoying, but seems to be required as the timeout parameter does
	# not listen, and instead just forces a broken pipe after about 5 seconds.
	def call(method, *args)
    @prefix = nil
		@client.call(method, *args)
	rescue Errno::EPIPE
    $stderr.puts "Had to restart the client! #{ Time.now }"
		@client = XMLRPC::Client.new(@host)
		@client.call(method, *args)
	end

  [ :f, :d, :p, :t, :system ].each do |prefix|
    define_method prefix do
      @prefix = prefix
      self
    end
  end

  def multicall(params, *methods)
    if @prefix
      # Perform the multi-call for them.
      
      results = call("#{@prefix}.multicall", *params, *methods.map do |e|
        s = e.to_s
        s = "#{@prefix}." + s unless s[0..1] =~ /(d|f|p|t)\.|(sy)/
        (s.to_s + "=")
      end)
      # nil this out for the next call

      results.map do |t|
        {}.tap do |properties_hash|
          methods.each_with_index { |e, i| properties_hash[e.to_sym] = t[i] }
        end
      end
    else
      $stderr.puts "Multicall used without a prefix!"
    end
  end
end

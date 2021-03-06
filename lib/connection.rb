require 'xmlrpc/client'

class Connection
	def initialize(host=nil)
		@host = host
		@client = XMLRPC::Client.new(@host)
	end

	# tragically annoying, but seems to be required as the timeout parameter does
	# not listen, and instead just forces a broken pipe after about 5 seconds.
	def call(method, *args)
		@client.call(method, *args)
	rescue Errno::EPIPE
    $stderr.puts "Had to restart the client! #{ Time.now }"
		@client = XMLRPC::Client.new(@host)
		@client.call(method, *args)
	end

  [ :f, :d, :p, :t, :system ].each do |prefix|
    define_method prefix do |&block|
      w = wrapper(prefix)
      if block_given?
        w.instance_eval &block
      else
        w
      end
    end
  end

  def multicall(prefix, params, *methods)
    puts "Executing: #{ prefix }.#{methods.inspect}"
    normalized_methods = *methods.map { |e| normalize prefix, e }

    results = call("#{prefix}.multicall", *params, *normalized_methods)

    results.map do |t|
      {}.tap do |properties_hash|
        puts properties_hash
        methods.each_with_index { |e, i| properties_hash[e.to_sym] = t[i] }
      end
    end.tap { |x| puts "Returning results..." }
  end

  private
  def wrapper(prefix)
    Wrapper.new self, prefix
  end

  def normalize(prefix, method)
    puts "Normalizing #{ method } to #{ prefix }"
    method = method.to_s
    method = "#{prefix}." + method unless method[0..1] =~ /(d|f|p|t)\.|(sy)/
    (method.to_s + (method[-1] == "=" ? "" : "="))
  end

  class Wrapper
    def initialize(connection, prefix)
      @connection = connection
      @prefix = prefix
    end

    def multicall(params, *methods)
      puts "forwarding #{@prefix}.#{methods.inspect} to: #{ @connection }"
      @connection.multicall(@prefix, params, *methods)
    end

    def call(method, *args)
      @connection.call(normalize(@prefix, method), *args)
    end
    
    def method_missing(method, *args, &block)
      @connection.send(method, args, block)
    end

    def respond_to?(method)
      return true if [:call, :multicall].include? method
      @connection.respond_to? method
    end
  end
end

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
      # Use like:
      # client.f do
      #   multicall(params, methods)
      #   call(method, args)
      # end
      wrapper(prefix).instance_eval &block
    end
  end

  def multicall(prefix, params, *methods)
    methods = *methods.map { |e| normalize prefix, e }

    results = call("#{prefix}.multicall", *params, methods)

    results.map do |t|
      {}.tap do |properties_hash|
        methods.each_with_index { |e, i| properties_hash[e.to_sym] = t[i] }
      end
    end
  end

  private
  def wrapper(prefix)
    wrapper = Class.new do
      def initialize(curr, prefix)
        @curr = curr
        @prefix = prefix
      end

      def multicall(params, *methods)
        @curr.multicall(@prefix, params, *methods)
      end

      def call(method, *args)
        @curr.call(normalize(@prefix, method), *args)
      end
    end
    wrapper.new self, prefix
  end

  def normalize(prefix, method)
    method = method.to_s
    method = "#{prefix}." + method unless method[0..1] =~ /(d|f|p|t)\.|(sy)/
    (method.to_s + (method[-1] == "=" ? "" : "="))
  end
end

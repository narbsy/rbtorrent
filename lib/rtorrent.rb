# TODO: FIX
# nop it for now
def puts(*args)
end

# Notes:
#		By convention, we assume that we have left Rtorrent's cwd at the download
#		directory.
class Rtorrent
	def initialize
		@client = Client.new config[:host]
	end

	def load(file, start = true)
		with_dir config["download-dir"] do
			puts "calling: load_start #{ file }"
			method = "load" + (start ? "_start" : "")
			@client.call(method, file).tap { |r| puts r }
		end
	end

  # Note, the ratio is calculated so that it can be sent as an integer over the
  # wire. It's got a precision of 3 places. real_ratio = get_ratio / 1000.0
	class Torrent
		# State of the torrent; define a method that caches results but can force refresh them.
		[ :get_size_chunks, :get_completed_chunks, :get_state, :get_name, :get_down_rate, 
			:get_down_total, :get_up_rate, :get_up_total, :get_ratio, :is_open, :get_complete ].each do |m|
			attr_reader m
			ivar_name = "@#{m}".to_sym
			define_method(m, ->(force = false) do
				i = instance_variable_get ivar_name
				puts "m: #{ivar_name} set to: #{i}: VAR IS #{ i ? "SET" : "NOT" }"
				if i.nil? || force
					r = @client.call("d.#{m}", @hash)
					puts "m: Setting #{ivar_name} to #{ r }"
					instance_variable_set ivar_name, r
				end
				instance_variable_get ivar_name
			end)
		end
	
		# Various manipulative actions
		[ :stop, :start, :erase ].each do |m|
			define_method m do
				@client.call "d.#{m}", get_hash
			end
		end

		private 
		def initialize(client, properties = {})
			@client = client
			raise ArgumentError unless (@hash = properties.delete(:get_hash))
			# quick start caches
			properties.each do |k,v|
				puts "i: Setting @#{k} to #{v}"
				instance_variable_set "@#{k}", v
			end
		end

		public
		# manipulate state

		def get_hash
			@hash
		end

		# query state

		def percentage
      return 0 if get_completed_chunks == 0
      (get_completed_chunks / get_size_chunks.to_f).round(4)
		end

		def get_status(force = false)
			if is_open(force) != 1
				return "Closed"
			end

			active = (get_state(force) != 0)
			complete = (get_complete(force) != 0)

			if !active && !complete then
				"Started"
			elsif active && !complete
				"Downloading"
			elsif !active && complete
				"Finished"
			elsif active && complete
				"Seeding"
			end
		end

    def self.get(hash)
      # No property loading in advance
      self.new( Client.new(config[:host]), get_hash: hash )
    end

    def self.all(args={})
      view = args.delete(:view) || "default"
      method = args.delete(:method) || "d"

      properties = args.delete(:properties)
      properties ||= [  :get_hash, :get_state, :get_ratio, :get_complete, 
                        :is_open, :get_size_chunks, :get_completed_chunks, 
                        :get_down_rate, :get_up_rate, :get_name ]

      client = Client.new config[:host]

      client.call("#{method}.multicall", view, *properties).map do |t|
        properties_hash = {}
        method_names.each_with_index { |e, i| properties_hash[e.to_sym] = t[i] }
        self.new(client, properties_hash)
      end
    end
	end

	def list(view, *args)
		method_names = args.map { |e| e.match(/(?:d|f|t|p)\.(.*)=/)[1] }
		@client.call("d.multicall", view, *args).map do |t|
			h = {}
			method_names.each_with_index { |e,i| h[e.to_sym] = t[i] }
			Torrent.new(@client, h)
		end
	end

	# Utility calls

	# i don't like this interface.
	# TODO: fix interface
	def from_hash(hash)
		Torrent.new( @client, get_hash: hash )
	end

	# Note that using get and set directory allow for correct adding of torrents;
	# this is likely because rtorrent does some extra stuff with these
	# internally.
	def cwd
		@client.call "get_directory"
	end

	def cwd=(dir)
		@client.call "set_directory", dir
	end

	# Helper method to clean up the
	# change-into-that-directory-for-a-sec-to-play-with-things problem.
	# Restores the old directory after yielding to clean up after itself,
	# and returns whatever value the block returned for consistency and ease of
	# use.
	def with_dir(directory)
		curr = self.cwd
		self.cwd = directory
		ret = yield
		self.cwd = curr
		ret
	end
end

class Rtorrent
  # Note, the ratio is calculated so that it can be sent as an integer over the
  # wire. It's got a precision of 3 places. real_ratio = get_ratio / 1000.0
	class Torrent
		def initialize(client, properties = {})
			@client = client
			raise ArgumentError unless (@hash = properties.delete(:get_hash))
			# quick start caches
			properties.each do |k,v|
				# puts "i: Setting @#{k} to #{v}"
				instance_variable_set "@#{k}", v
			end
		end

    private :initialize

		# State of the torrent; define a method that caches results but can force refresh them.
		[ :get_size_chunks, :get_completed_chunks, :get_state, :get_name, :get_down_rate, 
			:get_down_total, :get_up_rate, :get_up_total, :get_ratio, :is_open, :get_complete, 
      :get_size_files, :get_chunk_size ].each do |m|
			attr_reader m
			ivar_name = "@#{m}".to_sym
			define_method(m, ->(force = false) do
				i = instance_variable_get ivar_name
			  #	puts "m: #{ivar_name} set to: #{i}: VAR IS #{ i ? "SET" : "NOT" }"
				if i.nil? || force
					r = @client.call("d.#{m}", @hash)
					# puts "m: Setting #{ivar_name} to #{ r }"
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

    # We want these to be proper values
    [ :get_up_rate, :get_down_rate ].each do |rate|
      define_method rate do
        (@client.call("d.#{rate}", get_hash) / 1024).round(4)
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
      # TODO: This should also check for messages.

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

    # Get our multiple parts
    def files
      properties = [ :get_path ]
      index = 0
      @client.f.multicall( [get_hash, "0"], *properties ).map do |properties_hash|
        Torrent::TFile.new(@client, self, index, properties_hash).tap { index += 1 }
      end
    end

    def file(index)
      Torrent::TFile.new(@client, self, index)
    end

    def set_file_priorities(on_or_off)
      get_size_files.times do |i|
        @client.call "f.set_priority", get_hash, i, on_or_off[i.to_s] ? 1 : 0
      end
    end

    class << self
      def get(hash)
        # No property loading in advance
        self.new( Client.new(config[:host]), get_hash: hash )
      end

      def all(args={})
        view = args.delete(:view) || "default"

        properties = args.delete(:properties)
        properties ||= [  :get_hash, :get_state, :get_ratio, :get_complete, 
                          :is_open, :get_size_chunks, :get_completed_chunks, 
                          :get_down_rate, :get_up_rate, :get_name,
                          :get_size_files ]

        client = Client.new config[:host]

        client.d.multicall(view, *properties).map do |properties_hash|
          self.new(client, properties_hash)
        end
      end
    end
	end
end

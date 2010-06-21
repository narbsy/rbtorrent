require 'lib/remote_attr'

class Rtorrent
  # Inherit from BasicObject so that we are pretty sure we're not going to
  # override any methods.
	class Torrent < BasicObject
    extend ::RemoteAttr

    attr_reader :hash
    remote_attr :get_size_chunks, :get_completed_chunks, :get_state, :get_name, 
      :get_down_rate, :get_down_total, :get_up_rate, :get_up_total, :get_ratio, 
      :is_open, :get_complete, :get_size_files, :get_chunk_size,
      :prefix => :d, :default_arguments => [ method(:hash) ], :rubify => true


		def initialize(client, properties = {})
			@client = client
			raise ArgumentError unless (@hash = properties.delete(:get_hash))
			# quick start caches
			properties.each do |k,v|
        k = match[1] if (match = /get_(.*)/.match(k))
				instance_variable_set "@#{k}", v
			end
		end


    private :initialize

		# Various manipulative actions
		[ :stop, :start, :erase ].each do |m|
			define_method "#{m}!" do
				@client.call "d.#{m}", get_hash
			end
		end

    # We want these to be proper values
    [ :up_rate, :down_rate ].each do |rate|
      define_method rate do
        (@client.call("d.get_#{rate}", hash) / 1024).round(4)
      end
    end

		public
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

    # Doesn't do any pre-loading, making it *really* slow if used for multiple
    # files.
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

class Rtorrent
  class Torrent
    class TFile
      attr_reader :index

      def initialize(client, parent, index, properties = {})
        @client = client
        @parent = parent
        @index  = index.to_i # This needs to be an int, or else rtorrent complains
        # quick start caches
        properties.each do |k,v|
          # puts "i: Setting @#{k} to #{v}"
          instance_variable_set "@#{k}", v
        end
      end

      private :initialize

      [ :get_size_chunks, :get_completed_chunks, :get_path, :get_priority,
        :get_frozen_path, :get_last_touched, :get_match_depth_next,
        :get_match_depth_prev, :get_offset, :get_path_components,
        :get_path_depth, :get_range_first, :get_range_second,
        :get_size_bytes
      ].each do |m|
        attr_reader m
        ivar_name = "@#{m}".to_sym
        define_method(m, ->(force = false) do
          i = instance_variable_get ivar_name
          #	puts "m: #{ivar_name} set to: #{i}: VAR IS #{ i ? "SET" : "NOT" }"
          if i.nil? || force
            r = @client.call("f.#{m}", @parent.get_hash, @index)
            # puts "m: Setting #{ivar_name} to #{ r }"
            instance_variable_set ivar_name, r
          end
          instance_variable_get ivar_name
        end)
      end

      def percentage
        return 0 if get_completed_chunks == 0
        (get_completed_chunks / get_size_chunks.to_f).round(4)
      end

      # In MB
      def size
        (get_size_chunks * @parent.get_chunk_size) / (1024 * 1024)
      end

      def name
        get_path
      end

      def delete_physical_copy
        # puts "deleting: #{ File.join( config['download-dir'], @parent.get_name, name ) } "
        # system("rm #{ File.join( config['download-dir'], @parent.get_name, name ) }")
      end
    end
  end
end

require 'lib/remote_attr'

class Rtorrent
  class Torrent
    class TFile < BasicObject
      extend RemoteAttr

      attr_reader :index
      remote_attr :get_size_chunks, :get_completed_chunks, :get_path, :get_priority,
        :get_frozen_path, :get_last_touched, :get_match_depth_next,
        :get_match_depth_prev, :get_offset, :get_path_components,
        :get_path_depth, :get_range_first, :get_range_second,
        :get_size_bytes, 
        :prefix => :f, :default_arguments => [@parent.get_hash, @index],
        :rubify => true
      

      def initialize(client, parent, index, properties = {})
        @client = client
        @parent = parent
        @index  = index.to_i # This needs to be an int, or else rtorrent complains
        # quick start caches
        properties.each do |k,v|
          k = match[1] if (match = /get_(.*)/.match(k))
          instance_variable_set "@#{k}", v
        end
      end

      private :initialize

      def percentage
        return 0 if get_completed_chunks == 0
        (get_completed_chunks / get_size_chunks.to_f).round(4)
      end

      # In MB
      def size
        (get_size_chunks * @parent.get_chunk_size) / (1024 * 1024)
      end

      # Convenience alias
      def name
        path 
      end

      def delete_physical_copy
        # puts "deleting: #{ File.join( config['download-dir'], @parent.get_name, name ) } "
        # system("rm #{ File.join( config['download-dir'], @parent.get_name, name ) }")
      end
    end
  end
end

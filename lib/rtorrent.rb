class Rtorrent
  def initialize(client)
    @client = client
  end
  
  # Loads a file from a URL; eventually will support path-based.
	def load(directory, file, start = true)
		with_dir(directory) do
			puts "calling: load_start #{ file }"
			method = "load" + (start ? "_start" : "")
			@client.call(method, file).tap { |r| puts r }
		end
	end

	# Utility calls

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
    Rails.logger.info "Switching to: #{directory}"
		curr = self.cwd
    begin
      self.cwd = directory
      ret = yield
    ensure
      self.cwd = curr
    end
		ret
	end
end

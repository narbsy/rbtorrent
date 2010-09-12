class Rtorrent
	def initialize(connection)
    @connection = connection
	end

  # Loads a file from a URL; eventually will support path-based.
	def load(file, start = true)
		with_dir config["download-dir"] do
			puts "calling: load_start #{ file }"
			method = "load" + (start ? "_start" : "")
			@connection.call(method, file).tap { |r| puts r }
		end
	end

	# Utility calls

	# Note that using get and set directory allow for correct adding of torrents;
	# this is likely because rtorrent does some extra stuff with these
	# internally.
	def cwd
		@connection.call "get_directory"
	end

	def cwd=(dir)
		@connection.call "set_directory", dir
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

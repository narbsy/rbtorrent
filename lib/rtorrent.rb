# Notes:
#		By convention, we assume that we have left Rtorrent's cwd at the download
#		directory.
class Rtorrent
	def initialize
		@client = Client.new nil
	end

	def load(file, start = true)
		with_dir config["download-dir"] do
			puts "calling: load_start #{ file }"
			method = "load" + (start ? "_start" : "")
			@client.call(method, file).tap { |r| puts r }
		end
	end

	def stop(hash)
		@client.call "d.stop", hash
	end

	def start(hash)
		@client.call "d.start", hash
	end

	def erase(hash)
		@client.call "d.erase", hash
	end

	def list(view, *args)
		@client.call "d.multicall", view, *args
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
		curr = self.cwd
		self.cwd = directory
		ret = yield
		self.cwd = curr
		ret
	end

end

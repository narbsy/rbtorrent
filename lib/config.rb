# Load the configuration file firstly; may get rid of this later.
@@config = YAML.load_file 'config/conf.yaml'

# for prettiness and testability, return a config object that acts like a hash
def config
	@@config
end

def setup_download_dir!
	# try to make all parent directories as well. may well fail...
	FileUtils.mkdir_p config['download-dir']
	Rtorrent.new.cwd = config['download-dir']
end

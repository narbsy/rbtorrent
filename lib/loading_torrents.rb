require 'open-uri'

def read_remote_file(url)
  open(url).read
rescue Errno::ENOENT
  params[:errors] = "Could not open: #{ url }"
  nil
end

def write_local_file!(contents)
	name = hashed_name(contents)
  # Write the file locally so that rtorrent can read it
  file = File.join(config["torrent-dir"], name)

	if File.exists? file
    params[:errors] = "This torrent already exists!"
		return nil
	end

  File.open(file, "w") do |f|
    f.write contents
  end
	file
# Catch permissions error; if it is not owned by us, for example
rescue Errno::EACCES
  params[:errors] = "Could not write to: #{config["torrent-dir"]}"
  nil
# It won't automatically create the directory structure we require, so make
# sure we don't die on error.
rescue Errno::ENOENT
  params[:errors] = "No such file or directory! #{config["torrent-dir"]}"
  nil
end

def hashed_name(file_contents)
  "#{Digest::MD5.hexdigest(file_contents)}.#{Digest::SHA1.hexdigest(file_contents)}.torrent"
end


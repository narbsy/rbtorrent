module RemoteFiles
  require 'open-uri'

  def read_remote_file(url)
    open(url).read
  rescue Errno::ENOENT
    params[:errors] = "Could not open: #{ url }"
    nil
  end

  def write_local_file!(torrent_dir, contents, error_callback=nil)
    error_callback ||= lambda { |message| puts message }
    name = hashed_name(contents)
    # Write the file locally so that rtorrent can read it
    file_name = File.join(torrent_dir, name)

    if File.exists? file_name
      error_callback.call "This torrent already exists!"
      return nil
    end

    File.open(file_name, "w:ASCII-8BIT") do |f|
      f.write contents
    end
    file_name
  # Catch permissions error; if it is not owned by us, for example
  rescue Errno::EACCES
    error_callback.call "Could not write to: #{ torrent_dir }"
    nil
  # It won't automatically create the directory structure we require, so make
  # sure we don't die on error.
  rescue Errno::ENOENT
    error_callback.call "No such file or directory! #{ torrent_dir }"
    nil
  end

  def hashed_name(file_contents)
    "#{Digest::MD5.hexdigest(file_contents)}.#{Digest::SHA1.hexdigest(file_contents)}.torrent"
  end
end

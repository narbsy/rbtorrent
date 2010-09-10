require 'shellwords'

module TorrentHelper
  def escape(string)
    Shellwords.shellescape(string)
  end
end

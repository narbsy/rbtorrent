require 'datamapper'

DataMapper.setup :default, 'sqlite3:rbtorrent.db'

class User
  include DataMapper::Resource
  
  property :openid_identifier, String, :required => true, :key => true
end

DataMapper.auto_upgrade!

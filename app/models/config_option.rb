class ConfigOption
  include DataMapper::Resource

  property :name,   String, :unique => true, :key => true
  property :value,  String
end

class ConfigOption
  include DataMapper::Resource

  property :id,     Serial
  property :name,   String
  property :value,  String
end

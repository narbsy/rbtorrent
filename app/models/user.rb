class User
  include DataMapper::Resource

  property :id, Serial

  devise :database_authenticatable, :recoverable, :rememberable, :trackable
end

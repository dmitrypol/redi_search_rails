class User
  include ActiveModel::Model
  attr_accessor :name, :age
  include RediSearchRails
  redi_search_schema name: 'TEXT', age: 'NUMERIC'

  def to_global_id
    "gid://redi_search_rails/User/#{SecureRandom.uuid}"
  end

end

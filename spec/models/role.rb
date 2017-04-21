class Role
  include ActiveModel::Model
  attr_accessor :name

  include RediSearchRails
  redi_search_schema name: 'TEXT'

  def to_global_id
    "gid://redi_search_rails/Role/#{SecureRandom.uuid}"
  end

end

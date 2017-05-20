class User
  include ActiveModel::Model
  attr_accessor :name, :age, :email

  # extend ActiveModel::Callbacks
  # define_model_callbacks :save, :destroy

  include RediSearchRails
  redi_search_schema name: 'TEXT', email: 'TEXT', age: 'NUMERIC'

  def to_global_id
    "gid://redi_search_rails/User/#{SecureRandom.uuid}"
  end

end

# RediSearchRails

This gems simplifies integration with RediSearch module (http://redisearch.io/).  This software is of Alpha quality and is provided with no warranties whatsoever.  Additionally RediSearch is still not officially released so major features may change.  

## Installation

Install Redis and RediSearch following instructions on http://redisearch.io/Quick_Start/.  Until modules are released with Redis 4 this requires compiling Redis from unstable branch from GitHub.  

Add this line to your application's Gemfile:

```ruby
gem 'redi_search_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redi_search_rails

## Configuration

Create **config/initializers/redi_search_rails.rb**

```ruby
REDI_SEARCH = Redis.new(host: '127.0.0.1', port: '6379')
```

## Usage

```ruby
class User < ApplicationRecord
  include RediSearchRails
  redi_search_schema   name: 'TEXT', email: 'TEXT', age: 'NUMERIC'
end
# => to create index run in rails console
User.ft_create
# => populate index with records for all users
User.ft_add_all
# => or you can do it for specific record
User.ft_add(User.where(id: 1))
# => search
User.ft_search(keyword: 'keyword here', offset: 0, num: 10)
# => output
[1, "gid://application_name/User/unique_id", ["name", "Bob", "age", "100"]]
# => format results as array of hashes
User.ft_search_format(keyword: 'keyword here', offset: 0, num: 10)
# => output
[{"id": "gid://application_name/User/unique_id", "name": "Bob", "age": "100"}, {...}]
```

As unique identifier (doc_id) for records in Redis it uses https://github.com/rails/globalid.  You need to make sure you models support it if you are using ORM other than ActiveRecord.  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.  To understand the code look in `lib/redi_search_rails`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Testing this gem requires having local Redis with RediSearch module.  This makes it very difficult to set it up with services like Codeship.  

## TODOs

* ActiveModel callbacks to index records on saving and remove from Redis on delete
* Rake tasks to manage indexes
* Support additional RediSearch API calls (SUGGADD, SUGGET, ...)
* Support configuring SCORE, WEIGHT and other options
* Support indexing fields from related models (index group name if user belongs to a group)
* Stopwords configuration
* Minimum keyword length to index
* Configurable method for doc_id, not just default to_global_id
* More test coverage and documentation

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dmitrypol/redi_search_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

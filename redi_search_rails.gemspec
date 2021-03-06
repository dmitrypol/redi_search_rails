# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redi_search_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "redi_search_rails"
  spec.version       = RediSearchRails::VERSION
  spec.authors       = ["Dmitry Polyakovsky"]
  spec.email         = ["dmitrypol@gmail.com"]

  spec.summary       = %q{Simplifies integration with http://redisearch.io/.}
  spec.description   = %q{Simplifies integration with http://redisearch.io/ and Rails applications.}
  spec.homepage      = "https://github.com/dmitrypol/redi_search_rails"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "activemodel", ">= 4.2.8"
  spec.add_development_dependency "awesome_print"
  # =>
  spec.add_runtime_dependency "activesupport", ">= 4.2.8"
  spec.add_runtime_dependency "redis", "~> 3.3"
end

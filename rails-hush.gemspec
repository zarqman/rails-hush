$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rails_hush/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rails-hush"
  spec.version     = RailsHush::VERSION
  spec.authors     = ["thomas morgan"]
  spec.email       = ["tm@iprog.com"]
  spec.homepage    = "https://github.com/zarqman/rails-hush"
  spec.summary     = "Hushes worthless Rails exceptions & logs"
  spec.description = "Hushes worthless Rails exceptions & logs, such as those caused by bots and crawlers."
  spec.license     = "MIT"

  spec.metadata = {
    'source_code_uri' => 'https://github.com/zarqman/rails-hush',
    'changelog_uri' => 'https://github.com/zarqman/rails-hush/blob/master/CHANGELOG.md'
  }

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'rails', '>= 7', '< 8.2'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'minitest-reporters'
end

%w(show_exceptions simple_renderer hush_one hush_two).each do |f|
  require "rails_hush/middleware/#{f}"
end
require 'rails_hush/railtie'

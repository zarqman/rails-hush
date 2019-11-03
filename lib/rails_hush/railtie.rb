module RailsHush
  class Railtie < Rails::Railtie
    config.rails_hush          = ActiveSupport::OrderedOptions.new
    config.rails_hush.use_one  = true
    config.rails_hush.use_two  = true
    config.rails_hush.renderer = nil

    initializer 'railshush.init' do |app|
      if config.rails_hush.use_one
        app.middleware.insert 0, RailsHush::HushOne
      end
      if config.rails_hush.use_two
        app.middleware.insert_after ActionDispatch::DebugExceptions, RailsHush::HushTwo
      end
    end

  end
end

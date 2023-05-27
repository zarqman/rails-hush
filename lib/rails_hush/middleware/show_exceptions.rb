module RailsHush
  module ShowExceptions

    # actionpack treats missing/invalid values as :all/true. since railties (eg: a full rails
    # app) defaults to :all, skipping the invalid value case here to improve code clarity.
    # since rails-hush intentionally overrides certain exceptions, treat :rescuable the same
    # as :all. there's no need to be dynamic here.
    SHOWABLE = [
      :all,       # rails 7.1+
      true,       # rails 7.0-
      nil,        # equiv to :all,true
      :rescuable  # rails 7.1+
    ]

    def show_exceptions?(request, exception=nil)
      if Rails.version >= '7.1'
        SHOWABLE.include? request.get_header("action_dispatch.show_exceptions")
      else
        request.show_exceptions?
      end
    end

  end
end

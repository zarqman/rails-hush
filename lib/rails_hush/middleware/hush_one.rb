module RailsHush
  class HushOne
    include SimpleRenderer

    def initialize(app, renderer=nil)
      @app = app
      @renderer ||= Rails.application.config.rails_hush.renderer || method(:default_renderer)
    end

    def call(env)
      request = ActionDispatch::Request.new env
      if request.show_exceptions? && !request.get_header("action_dispatch.show_detailed_exceptions")
        begin
          @app.call(env)
        rescue ActionController::UnknownHttpMethod
          render 405, request, 'Unrecognized HTTP method'
        end
      else
        @app.call(env)
      end
    end

  end
end

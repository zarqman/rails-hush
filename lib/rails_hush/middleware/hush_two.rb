module RailsHush
  class HushTwo
    include ShowExceptions
    include SimpleRenderer

    def initialize(app, renderer=nil)
      @app = app
      @renderer ||= Rails.application.config.rails_hush.renderer || method(:default_renderer)
    end

    def call(env)
      request = ActionDispatch::Request.new env
      if show_exceptions?(request) && !request.get_header("action_dispatch.show_detailed_exceptions")
        begin
          _, headers, body = response = @app.call(env)
          if headers['X-Cascade'] == 'pass' || headers['x-cascade'] == 'pass'
            body.close if body.respond_to?(:close)
            raise ActionController::RoutingError, "No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}"
          end
          response

        rescue ActionController::BadRequest => x
          if x.message =~ /(Invalid encoding for parameter|invalid %-encoding)/
            log_request 400, request
            render 400, request, 'Invalid string or encoding'
          else
            raise x
          end
        rescue ActionDispatch::Http::Parameters::ParseError
          log_request 400, request
          render 400, request, 'Unable to parse request body'
        rescue ActionController::RoutingError => x
          log_request 404, request
          render 404, request
        rescue ActionController::UnknownHttpMethod
          log_request 405, request
          render 405, request, 'Unrecognized HTTP method'
        rescue ActionController::UnknownFormat
          render 406, request, 'Invalid format'
        rescue Mime::Type::InvalidMimeType
          log_request 406, request
          render 406, request, 'Invalid media type'
        rescue ActionController::ParameterMissing => x
          render 422, request, "Required parameter missing or empty: #{x.param}"
        rescue ActionController::InvalidAuthenticityToken
          render 422, request, 'Invalid CSRF token'
        end
      else
        @app.call(env)
      end
    end

  end
end

module RailsHush
  module SimpleRenderer

    def log_request(status, request)
      payload = {
        params: (request.filtered_parameters rescue {}),
        headers: request.headers,
        format: (request.format.ref rescue :text),
        method: (request.request_method rescue 'INVALID'),
        path: request.fullpath,
        status: status
      }
      ActiveSupport::Notifications.instrument "process_action.action_controller", payload
    end

    def render(status, request, error=nil)
      begin
        content_type = request.formats.first
      rescue Mime::Type::InvalidMimeType,
             Encoding::CompatibilityError,
             Rack::Multipart::BoundaryTooLongError
        content_type = Mime[:text]
      end
      error ||= Rack::Utils::HTTP_STATUS_CODES.fetch(status, Rack::Utils::HTTP_STATUS_CODES[500])
      @renderer.call(status, content_type, error)
    end

    def default_renderer(status, content_type, error)
      body = { status: status, error: error }
      format = "to_#{content_type.to_sym}" if content_type
      if format && body.respond_to?(format)
        body = body.public_send(format)
      else
        content_type = 'application/json'
        body = body.to_json
      end
      [status, { "Content-Type" => "#{content_type}; charset=#{ActionDispatch::Response.default_charset}",
                "Content-Length" => body.bytesize.to_s }, [body]]
    end

  end
end

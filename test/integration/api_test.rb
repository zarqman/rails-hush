require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest

  test "Public page" do
    get '/good'
    assert_response 200
  end

  test "Valid Accept -> 200" do
    [ 'application/json',
      'application/xml',
      'text/html',
    ].each do |ac|
      get '/resources', headers: {'HTTP_ACCEPT' => ac}
      assert_response 200, "for #{ac.inspect}"
    end
  end

  test "Invalid % encoding (path) -> 400" do
    # Two => ActionController::BadRequest / Invalid path parameters: Invalid encoding for parameter: 345x
    get '/resources/345%fa'
    assert_response 400
    assert_api_message %r{Invalid string or encoding}
  end

  test "Invalid % encoding (query) -> 400" do
    # Two => ActionController::BadRequest / Invalid query parameters: Invalid encoding for parameter: 345x
    get '/resources/1234?q=345%fa'
    assert_response 400
    assert_api_message %r{Invalid string or encoding}
  end

  test "Invalid % encoding (payload) -> 400" do
    # Two => ActionController::BadRequest / Invalid request parameters: invalid %-encoding ({invalid: "%form"})
    post '/resources', params: +'{invalid: "%form"}'
    assert_response 400
    assert_api_message %r{Invalid string or encoding}
  end

  test "Invalid json -> 400" do
    # Two => ActionDispatch::Http::Parameters::ParseError / 767: unexpected token at '{invalid: "json"}'
    post '/resources', params: +'{invalid: "json"}', headers: default_headers.merge('Content-Type': Mime[:json].to_s)
    assert_response 400
    assert_api_message %r{Unable to parse}

    # Two => ActionController::ParameterMissing
    #   effectively becomes same as 422 test below
    post '/resources', params: +'{invalid: "form"}', headers: default_headers.merge('Content-Type': Mime[:url_encoded_form].to_s)
    assert_response 422
    # result: bad param is safely neutered

    post "/resources", params: +'invalid-multipart', headers: default_headers.merge('Content-Type': Mime[:multipart_form].to_s)
    assert_response 422
    # bad param is safely neutered
  end

  test "Invalid route -> 404" do
    # Two => ActionController::RoutingError / No route matches [GET] "/invalid/route"
    [ '/invalid/route',
    ].each do |path|
      get path
      assert_response 404
      assert_api_message %r{Not found}i
    end
  end

  test "Invalid method -> 405" do
    # One => ActionController::UnknownHttpMethod / FAKE_METHOD, accepted HTTP methods are ...
    process :fake_method, '/resources', params: +'{}'
    assert_response 405
    assert_api_message %r{Unrecognized HTTP method}
  end

  test "Invalid Accept -> 406" do
    # Two => Mime::Type::InvalidMimeType / "junk" is not a valid MIME type
    [ 'junk',
      'text',
      'text/',
    ].each do |ac|
      get '/resources', headers: {'HTTP_ACCEPT' => ac}
      assert_response 406
      assert_api_message %r{Invalid media type}
    end

    # Two => ActionController::UnknownFormat
    [ 'image/png',
    ].each do |ac|
      get '/resources', headers: {'HTTP_ACCEPT' => ac}
      assert_response 406
      assert_api_message %r{Invalid format}
    end
  end

  test "Unsupported :format -> 406" do
    # Two => ActionController::UnknownFormat
    [ 'js',
      'png'
    ].each do |fmt|
      get "/resources.#{fmt}"
      assert_response 406
      assert_api_message %r{Invalid format}
    end
  end

  test "Missing params -> 422" do
    # Two => ActionController::ParameterMissing / param is missing or the value is empty: resource
    post '/resources', params: {}
    assert_response 422
    assert_api_message %r{Required parameter missing}
  end

  test "Invalid CSRF -> 422" do
    # Two => ActionController::InvalidAuthenticityToken
    post '/csrf_resources', params: {authenticity_token: 'invalid'}
    assert_response 422
    assert_api_message %r{Invalid CSRF token}
  end



  def default_headers
    {'HTTP_ACCEPT' => 'application/json'}
  end

  def get(path, **args)
    args[:headers] ||= default_headers
    super
  end

  def post(path, **args)
    args[:headers] ||= default_headers
    super
  end


  def assert_api_message(regex, json=json_response, message=nil)
    assert json.key?('error'), "JSON missing :error key (Actual: #{json.inspect})"
    json['error'] =~ regex || flunk(message || "JSON missing message matching #{regex} (Actual: #{json.inspect})")
  end

  def json_response
    if response.body.blank?
      {}
    else
      JSON.parse(response.body)
    end
  rescue JSON::ParserError
    puts "Body: #{body.inspect}"
    raise
  end

end

# RailsHush

RailsHush hushes worthless Rails exceptions & logs, such as those caused by bots and crawlers.

Rails generates a number of exceptions that, while useful in development, are quite noisy in production. This is expecially true because of the volume of bots deliberately sending malformed traffic to your Rails app. Unfortunately, by default Rails dutifully logs exceptions and backtraces for all of this, and depending on your exception notification system of choice, may trigger unnecessary notifications.

In addition to bots, if your app has an API and is used by third-parties, they may generate a variety of errors while integrating with your app. These too don't need to be logged, but it is useful if the error messages are more helpful than simply "bad request". RailsHush takes care of this for you.

RailsHush will...

* Silence backtrace logging for a wide array of errors that aren't related to your actual app code
* Return various 4xx HTTP status codes, instead of 500
* Provide basic, helpful error messages to 3rd-parties integrating with your app
* Properly trigger "Completed..." log entries at the end of invalid requests
  * Using standard active_support notifications, for compatibility with non-default logging solutions

RailsHush honors Rails settings for `show_exceptions` and `consider_all_requests_local`. With Rails' defaults, it will only activate in production and will not interfere with debugging while in development or test. The exceptions that are hushed are very selective; actual app errors should continue to raise exceptions as normal, even in production.


## Installation
Add this line to your Rails application's Gemfile:

```ruby
gem 'rails-hush'
```

And then execute:
```bash
$ bundle
```


## Usage

By default, works automatically upon installation. Most of the time, configuration is not necessary.


#### Configuration

RailsHush does support a couple of configuration options:

To disable automatic loading of middleware:

    # Phase one (early) middleware
    config.rails_hush.use_one  = false
    # Phase two (late) middleware
    config.rails_hush.use_two  = false

Then add the middleware on your own:

    # Phase one
    app.middleware.insert 0, RailsHush::HushOne
    # Phase two
    app.middleware.insert_after ActionDispatch::DebugExceptions, RailsHush::HushTwo

RailsHush also has a replaceable renderer, in case you don't like the default json/xml output:

    config.rails_hush.renderer = lambda do |status, content_type, error|
      # status       - integer, eg: 400
      # content_type - a Mime::Type instance, eg: Mime[:json]
      # error        = RailsHush's default text error message, eg: "some error"
      #                You may replace it with your own based on status or anything else.
      ...
      # the block must return a Rack-compatible response:
      headers = {}
      body = {my: 'payload'}.to_json
      [status, headers, [body]]
    end


#### Testing

Rails' default "test" environment settings are quite different than "production". While the default settings are quite appropriate, with them it is near impossible to test the actual behavior of RailsHush, because it will effectively be disabled in "test". On the whole, it's recommended to just rely on RailsHush's own test suite. However, if you really want to test its behavior inside your app, change the following in `environments/test.rb`:

    config.consider_all_requests_local     = false
    config.action_dispatch.show_exceptions = true


## Contributing

Contributions welcome. Please use standard GitHub Pull Requests.


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

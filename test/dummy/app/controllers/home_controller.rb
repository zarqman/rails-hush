class HomeController < ApplicationController
  rate_limit to: 1, within: 2.seconds, by: ->{ request.remote_ip }, only: :ratelimited

  def good
    head 200
  end

  def ratelimited
  end

end

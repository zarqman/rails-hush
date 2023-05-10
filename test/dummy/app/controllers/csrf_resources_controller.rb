class CsrfResourcesController < ResourcesController
  include ActionController::RequestForgeryProtection
    # this is disabled by default when env=test
  protect_from_forgery with: :exception
end

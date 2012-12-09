# This file is used by Rack-based servers to start the application.

require '../madeleine-middleware.rb'
use Madeleine::Rack::Middleware

require ::File.expand_path('../config/environment',  __FILE__)
run Sampleapp::Application

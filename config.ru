
require './madeleine-middleware'
require 'rack'
require 'rack/lobster'

use Madeleine::Middleware
run Rack::Lobster.new

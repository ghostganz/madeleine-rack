
require './madeleine-middleware'
require 'rack'
require 'rack/lobster'

use Madeleine::Rack::Middleware

#run Rack::Lobster.new

require './sample'
run Sample.new


require './madeleine-middleware'
require 'rack'
require 'rack/lobster'

use Madeleine::Middleware
map "/" do
  run Rack::Lobster
end

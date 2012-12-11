
require 'madeleine-rack'

use Madeleine::Rack::Middleware, "some_storage"

require './sample'
run Sample.new

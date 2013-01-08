
require 'madeleine-rack'

use Rack::Lint
use Madeleine::Rack::Middleware, "some_storage"
use Rack::Lint

require './sample'
run Sample.new

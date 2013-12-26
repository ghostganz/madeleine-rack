
require 'madeleine-rack'

use Rack::Lint
use Madeleine::Rack::Middleware, "io_storage"
use Rack::Lint

require './sample-io'
run SampleIO.new

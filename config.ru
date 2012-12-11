
require 'madeleine-rack'

use Madeleine::Rack::Middleware

require './sample'
run Sample.new

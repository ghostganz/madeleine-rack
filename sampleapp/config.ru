# This file is used by Rack-based servers to start the application.

$LOAD_PATH.push '../lib'

trap("SIGHUP") do
  Thread.list.each do |t|
    puts "---------------"
    puts t.backtrace
  end
end

require 'madeleine-rack'

use Madeleine::Rack::Middleware, "sampleapp_storage"

require ::File.expand_path('../config/environment',  __FILE__)
run Sampleapp::Application

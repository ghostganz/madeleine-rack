# -*- coding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'madeleine/rack/version'

Gem::Specification.new do |s|
  s.name = 'madeleine-rack'
  s.version = Madeleine::Rack::VERSION

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9.3"
  s.require_path = 'lib'

  s.author = "Anders Bengtsson"
  s.email = "ndrsbngtssn@yahoo.se"
  s.homepage = "http://github.com/ghostganz/madeleine-rack"

  s.files = Dir.glob("lib/**/*.rb") +
    ['README', 'COPYING']

  s.add_dependency 'madeleine', '0.8.0.pre'
  s.add_dependency 'rack', '1.4.1' # Need to be picky about version, since internal changes may break us
  s.add_development_dependency 'rails'
end

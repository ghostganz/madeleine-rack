# -*- coding: utf-8 -*-

require 'rack'
require 'net/http'
require 'queue'

class IoService
  def initialize
    @queue = Queue.new
  end

  def enqueue(url, id)
    @queue << [url, id]
  end

  def work
    url, id = @queue.pop
    html = Net::HTTP.get(uri)

    # TODO send update to mad.
  end
end



class SampleIO
  def initialize
    @io_service = IoService.new
    Thread.new do
      loop do
        @io_service.work
      end
    end
  end

  def call(env)
    logger = env['rack.logger']
    system = Thread.current[:_madeleine_system]

    req = Rack::Request.new(env)
    if req.get?
      content = []
      if system[:title]
        content << "Title: " + system[:title]
      end
      content << "<form method='post' action='/' encoding='multipart/form-data'><input name='url'></form>"
      [200, {"Content-Type" => "text/html"}, content]
    elsif req.post?
      url_param = req.POST['url']
      uri = URI(url_param)


      # Ha en generell IO-mojäng som kör saker async, och ha all logik i ett objekt som instansieras
      # och registreras härifrån?...

      # TODO this is the stuff that needs to run on outside
      html = Net::HTTP.get(uri)

      # TODO this is the stuff that needs to run on callback
      if html =~ /\<title\>(.*)\<\/title\>/m
        system[:title] = $1
      end

      [302, {'Location' => '/', 'Content-Type' => 'text/plain'}, ['redirect']]
    else
      [400, {"Content-Type" => "text/html"}, ['Dunno bout that']]
    end
  end
end

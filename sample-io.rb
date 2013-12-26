# -*- coding: utf-8 -*-

require 'rack'
require 'net/http'

class IoService
  def initialize
    @queue = Queue.new
  end

  def enqueue(url, id, madeleine)
    return if madeleine.in_recovery? # Protected from race cond. only by being called from within a command, so be careful.
    @queue << [url, id, madeleine]
  end

  def work
    url, id, madeleine = @queue.pop

    puts "Fetching url: #{url}"
    html = Net::HTTP.get(url)

    puts "Executing with #{html.size} bytes of html"
    madeleine.execute_command(IoUpdate.new(id, html))
  end
end

# TODO combine update/callback?

class IoUpdate
  def initialize(id, html)
    @id, @html = id, html
  end

  def execute(system, context)
    puts "In execute..."
    callback = system[:pending_io].delete(@id)
    puts "Calling callback: #{callback}"
    callback.call(@html, system)
  end
end

class IoCallback

  def call(html, system)
    puts "Got html: #{html.size} bytes"
    if html =~ /\<title\>(.*)\<\/title\>/m
      puts "Got a title"
      system[:title] = $1
    end
  end
end

# TODO set up IoService from another middleware? (but want it stand-alone too)

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
    system = env['madeleine.system']

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

      system[:pending_io] ||= {}
      id = 'the-id' # TODO
      system[:pending_io][id] = IoCallback.new

      @io_service.enqueue(uri, id, env['madeleine.madeleine'])

      [302, {'Location' => '/', 'Content-Type' => 'text/plain'}, ['redirect']]
    else
      [400, {"Content-Type" => "text/html"}, ['Dunno bout that']]
    end
  end
end

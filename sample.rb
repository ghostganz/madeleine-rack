
require 'rack'

class Sample

  def call(env)
    logger = env['rack.logger']
    logger.info("CALL")
    system = Thread.current[:_madeleine_system]
    req = Rack::Request.new(env)
    if req.get?
      logger.info("GET")
      content = []
      content << "<p>Current value is: #{system[:value]}</p>"
      content << "<form method='post' action='/' encoding='multipart/form-data'><input name='state' value='#{system[:value]}'/></form>"
      [200, {"Content-Type" => "text/html"}, content]
    elsif req.post?
      logger.info("POST(state=#{req.POST['state']})")
      system[:value] = req.POST['state']
      [302, {'Location' => '/', 'Content-Type' => 'text/plain'}, ['redirect']]
    else
      logger.info("XXX")
    end
  end
end

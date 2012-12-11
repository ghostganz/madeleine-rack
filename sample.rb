
require 'rack'

class Sample

  def call(env)
    puts "CALL"
    system = Thread.current[:_madeleine_system]
    req = Rack::Request.new(env)
    if req.get?
      puts "GET"
      content = []
      content << "<p>Current value is: #{system[:value]}</p>"
      content << "<form method='post' action='/' encoding='multipart/form-data'><input name='state' value='#{system[:value]}'/></form>"
      [200, {"Content-Type" => "text/html"}, content]
    elsif req.post?
      puts "POST(state=#{req.POST['state']})"
      system[:value] = req.POST['state']
      [302, {'Location' => '/', 'Content-Type' => 'text/plain'}, ['redirect']]
    else
      puts "XXX"
    end
  end
end

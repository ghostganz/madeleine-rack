# madeleine-rack: Madeleine persistence for Rack-based applications

**madeleine-rack** is a [Rack](http://rack.github.com/) middleware that uses
[Madeleine](https://github.com/ghostganz/madeleine) to provide data persistence
to web applications.

It does this by intercepting and storing all web requests, so that the
application's state can later be restored by automatically re-playing the
requests.

It supports the basic Rack [specification](https://github.com/rack/rack/blob/master/SPEC),
with a few work-arounds for specific web servers, etc.

### Usage

Add something like this to your ```config.ru``` file:

```
use Madeleine::Rack::Middleware, "some_storage"
```

Then use something Rack-based (e.g. ```rackup```) to start the application.

You will find your persistent system root in

```
Thread.current[:_madeleine_system]
```

from within your application.

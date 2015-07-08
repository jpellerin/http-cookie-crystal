require "./http-cookie/*"

module Http::Cookie

  extend self

  def parse(set_cookie, origin, options=nil)
    cookies = [] of Cookie
    Scanner.new(set_cookie, logger).scan_set_cookie{ |name, value, attrs|
      if name && value
        c = Cookie.new(name, value, origin, attrs)
        cookies << c
      end
    }
    cookies
  end

  def parse(set_cookie, origin, options=nil, &block)
    Scanner.new(set_cookie, logger).scan_set_cookie{ |name, value, attrs|
      if name && value
        c = Cookie.new(name, value, origin, attrs)
        yield c
      end
    }
  end

  # TODO
  def cookie_value(cookies)

  end

  # FIXME
  def logger
  end

end

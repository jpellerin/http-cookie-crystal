require "./http-cookie/*"

module Http::Cookie

  extend self

  def parse(set_cookie, origin, options=nil, &block)
    cookies = [] of Cookie
    Scanner.new(set_cookie, logger).scan_set_cookie{ |name, value, attrs|


    }

    cookies
  end

end

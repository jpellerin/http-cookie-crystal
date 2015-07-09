require "./cookie"

module HTTP

  class CookieJar
    property cookies

    def initialize
      @cookies = [] of HTTP::Cookie::Cookie
    end

    def initialize(@cookies : Array(HTTP::Cookie::Cookie))
    end

    def parse(set_cookie, origin, options=nil, &block)
      HTTP::Cookie.parse(set_cookie, origin, options).tap { |cookies|
        cookies.select! { |cookie|
          yield(cookie) && add(cookie)
        }
      }
    end

    def parse(set_cookie, origin, options=nil)
      HTTP::Cookie.parse(set_cookie, origin, options) { |cookie|
        add(cookie)
      }
    end

    def add(cookie)
      @cookies << cookie
    end
  end
end

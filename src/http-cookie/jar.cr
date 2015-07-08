require "./cookie"

module Http

  class CookieJar
    property cookies

    def initialize
      @cookies = [] of Http::Cookie::Cookie
    end

    def initialize(@cookies : Array(Http::Cookie::Cookie))
    end

    def parse(set_cookie, origin, options=nil, &block)
      Http::Cookie.parse(set_cookie, origin, options).tap { |cookies|
        cookies.select! { |cookie|
          yield(cookie) && add(cookie)
        }
      }
    end

    def parse(set_cookie, origin, options=nil)
      Http::Cookie.parse(set_cookie, origin, options) { |cookie|
        add(cookie)
      }
    end

    def add(cookie)
      @cookies << cookie
    end
  end
end

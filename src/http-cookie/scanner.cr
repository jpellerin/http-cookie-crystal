require "string_scanner"
require "time"
require "time/time_format"

module Http::Cookie
  class Scanner < StringScanner
    WHITESPACE = /[ \t]+/
    NAME = /(?!#{WHITESPACE})[^,;\\"=]*/
    INVALID_CHAR = /([\x00-\x20\x7F",;\\])/
    COOKIE_COMMA = /,(?=#{WHITESPACE}?#{NAME}=)/

    # Wdy, DD Mon YYYY HH:MM:SS GMT (RFC 6265 5.1.1)
    DATE_FMT = TimeFormat.new("%a %d %b %Y %H:%M:%S %z", kind=Time::Kind::Utc)

    def initialize(str, @logger=nil)
      super(str)
    end

    def scan_set_cookie
      until eos?
        start = @offset
        len = nil
        skip WHITESPACE
        name, value = scan_name_value
        attrs = {} of String => (String|Bool|Time)
        case

        when skip(/,/)
          len = (@offset - 1) - start
          break
        when skip(/;/)
          skip WHITESPACE
          attr_name, attr_value = scan_name_value
          unless attr_name && attr_value
            next
          end
          attr_name = attr_name.downcase
          case attr_name
          when "expires"
            # RFC 6265 5.2.1
            next unless attr_value = parse_cookie_date(attr_value)
          when "max-age"
            # RFC 6265 5.2.2
            next unless /\A-?\d+\z/.match(attr_value)
          when "domain"
            # RFC 6265 5.2.3
            # An empty value SHOULD be ignored.
            next unless attr_value && attr_value.length > 0
          when "path"
            # RFC 6265 5.2.4
            # A relative path must be ignored rather than normalizing it
            # to "/".
            next unless /\A\//.match(attr_value)
          when "secure", "httponly"
            # RFC 6265 5.2.5, 5.2.6
            attr_value = true
          end

          attrs[attr_name] = attr_value
        end until eos?

      end
      if start
        len ||= @offset - start
      else
        len ||= @offset
      end
      # FIXME more validations
      yield name, value, attrs if value
    end

    def scan_dquoted
      s = ""
      case
      when skip(/"/)
        break
      when skip(/\\/)
        s += getch
      when matched = scan(/[^"\\]+/)
        s += matched
      end until eos?
      s
    end

    def scan_name
      s = scan(NAME)
      s.rstrip if s
    end

    def scan_value
      s = ""
      case
      when matched = scan(/[^,;"]+/)
        s += matched
      when skip(/"/)
        # RFC 6265 2.2
        # A cookie-value may be DQUOTE'd.
        s += scan_dquoted
      when check(/;|#{COOKIE_COMMA}/)
        break
      else
        s += getch
      end until eos?
      s.rstrip if s
    end

    def scan_name_value
      name = scan_name
      if skip(/\=/)
        value = scan_value
      else
        scan_value
        value = nil
      end
      {name, value}
    end

    def skip(re)
      if scan(re)
        true
      else
        false
      end
    end

    def check(re)
      match = re.match(@str, @offset, Regex::Options::ANCHORED)
      if match
        true
      else
        false
      end
    end

    def getch
      unless eos?
        c = @str[@offset]
        @offset += 1
        c
      end
      ""
    end

    def parse_cookie_date(s)
      DATE_FMT.parse(s)
    end
  end
end

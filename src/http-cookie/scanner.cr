require "string_scanner"

module Http::Cookie
  class Scanner < StringScanner
    WHITESPACE = /[ \t]+/
    NAME = /(?!#{WHITESPACE})[^,;\\"=]*/
    INVALID_CHAR = /([\x00-\x20\x7F",;\\])/
    COOKIE_COMMA = /,(?=#{WHITESPACE}?#{NAME}=)/

    def initialize(str, @logger=nil)
      super(str)
    end

    def scan_set_cookie
      # FIXXXME
      until eos?
        start = @offset
        len = nil
        skip WHITESPACE
        name, value = scan_name_value
        attrs = {} of String => String
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
          # FIXME validations
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

  end
end

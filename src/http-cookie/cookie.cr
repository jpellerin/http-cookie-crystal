require "time"

module HTTP::Cookie
  class Cookie
    property name
    property value
    property domain
    property origin
    property path
    property expires
    property max_age

    def initialize(@name : String, @value : String)
    end

    def initialize(@name : String, @value : String,
                   @domain=nil : String?, @origin=nil : String?,
                   @path=nil : String?, @expires=nil : Time?,
                   @max_age=nil : Number?)
    end

    def initialize(@name : String, @value : String, @origin : String?,
                   attrs : Hash(String, _))
      attrs.each { |k, v|
        case k
        when "domain"
          @domain = v as String
        when "path"
          @path = v as String
        when "expires"
          @expires = v as Time
        when "max-age"
          @max_age = v.to_s.to_i
        end
      }
    end
  end
end

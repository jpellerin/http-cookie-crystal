require "./spec_helper"

describe HTTP::Cookie::Scanner do
  # TODO: Write tests

  it "trivially works for empty input" do
    s = HTTP::Cookie::Scanner.new("")
    s.scan_set_cookie{}
  end

  it "can parse a cookie" do
    s = HTTP::Cookie::Scanner.new("foo=bar; x=y;")
    s.scan_set_cookie { |name, value, attr |
      name.should eq("foo")
      value.should eq("bar")
      attr.should eq({"x": "y"})
    }
  end

  it "can parse a valid cookie date" do
    s = HTTP::Cookie::Scanner.new("PREF=1; expires=Wed, 08 Jul 2015 12:34:56 GMT")
    s.scan_set_cookie{ |name, value, attr|
      if attr
        a_t = attr["expires"] as Time
        if a_t
          a_t.month.should eq(7)
          a_t.day.should eq(8)
          a_t.year.should eq(2015)
          a_t.hour.should eq(12)
          a_t.minute.should eq(34)
          a_t.second.should eq(56)
        else
          fail "Invalid time attr #{attr["expires"]}"
        end
      else
        fail "No attributes in cookie"
      end
    }

  end

  # XXX unclear if the expectation here is desirable behavior.
  #     should we really accept invalidly-formatted cookie dates?
  # it "can parse weird cookie dates" do
  #   [
  #     {"PREF=1; expires=Wed, 01 Jan 100 12:34:56 GMT", nil},
  #     {"PREF=1; expires=Sat, 01 Jan 1600 12:34:56 GMT", nil},
  #     {"PREF=1; expires=Tue, 01 Jan 69 12:34:56 GMT", 2069},
  #     {"PREF=1; expires=Thu, 01 Jan 70 12:34:56 GMT", 1970},
  #     {"PREF=1; expires=Wed, 01 Jan 20 12:34:56 GMT", 2020},
  #     {"PREF=1; expires=Sat, 01 Jan 2020 12:34:60 GMT", nil},
  #     {"PREF=1; expires=Sat, 01 Jan 2020 12:60:56 GMT", nil},
  #     {"PREF=1; expires=Sat, 01 Jan 2020 24:00:00 GMT", nil},
  #     {"PREF=1; expires=Sat, 32 Jan 2020 12:34:56 GMT", nil},
  #   ].each { |a|
  #     set_cookie, year = a
  #     s = HTTP::Cookie::Scanner.new(set_cookie)
  #     s.scan_set_cookie{ |name, value, attr|
  #       if attr
  #         a_t = attr["expires"] as Time
  #         if a_t
  #           if year
  #             a_t.year.should eq(year)
  #           else
  #             a_t.year.should eq(nil)
  #           end
  #         end
  #       end
  #     }
  #   }
  # end

end

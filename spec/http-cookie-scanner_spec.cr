require "./spec_helper"

describe Http::Cookie::Scanner do
  # TODO: Write tests

  it "trivially works for empty input" do
    s = Http::Cookie::Scanner.new("")
    s.scan_set_cookie{}
  end

  it "can parse a cookie" do
    s = Http::Cookie::Scanner.new("foo=bar; x=y;")
    s.scan_set_cookie { |name, value, attr |
      name.should eq("foo")
      value.should eq("bar")
      attr.should eq({"x": "y"})
    }
  end
end

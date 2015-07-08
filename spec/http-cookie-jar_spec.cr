require "./spec_helper"

describe Http::CookieJar do

  it "can parse and store a cookie" do
    jar = Http::CookieJar.new
    jar.parse(
      "PREF=1; expires=Wed, 08 Jul 2015 12:34:56 GMT",
      "foo.com")

    ck = jar.cookies[0]
    ck.name.should eq("PREF")
    ck.value.should eq("1")
    ck.expires.should eq(Time.new(2015, 7, 8, 12, 34, 56))
    ck.domain.should eq(nil)
    ck.path.should eq(nil)
    ck.max_age.should eq(nil)
    ck.origin.should eq("foo.com")
  end
end

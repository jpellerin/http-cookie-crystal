require "./spec_helper"

describe HTTP::Cookie do

  it "can parses a header and make a cookie" do
    cookies = HTTP::Cookie.parse(
      "PREF=1; expires=Wed, 08 Jul 2015 12:34:56 GMT",
      "foo.com")

    ck = cookies[0]
    ck.name.should eq("PREF")
    ck.value.should eq("1")
    ck.expires.should eq(Time.new(2015, 7, 8, 12, 34, 56))
    ck.domain.should eq(nil)
    ck.path.should eq(nil)
    ck.max_age.should eq(nil)
    ck.origin.should eq("foo.com")
  end


end

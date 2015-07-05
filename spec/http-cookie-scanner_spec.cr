require "./spec_helper"

describe Http::Cookie::Scanner do
  # TODO: Write tests

  it "trivially works for empty input" do
    s = Http::Cookie::Scanner.new([] of String)
    s.scan_set_cookie
  end
end

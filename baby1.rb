require "minitest/autorun"
require "time"

def nightly_charge(start_time, end_time)
  raise "Started before 5:00PM"
end

describe "The babysitter" do
  it "starts no earlier than 5:00PM" do
    lambda {
      nightly_charge Time.parse("4:00PM"), Time.parse("6:00PM")
    }.must_raise StandardError
  end
end
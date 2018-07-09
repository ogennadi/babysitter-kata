require "minitest/autorun"
require "time"

def nightly_charge(start_time, end_time)
  adjusted_start = start_time + hours_to_seconds(7)
  adjusted_end   = end_time   + hours_to_seconds(7)
  
  if adjusted_start.hour % 24 > 11
    raise "Started before 5:00PM"
  end

  if adjusted_end.hour % 24 > 11
    raise "Ended after 4:00AM"
  end
end

# Returns NUM hours in seconds
def hours_to_seconds(num)
  num * 60 * 60
end

describe "The nightly charge" do
  before do
    @three_am   = Time.parse("03:00")
    @six_pm     = Time.parse("18:00")
    @five_am    = Time.parse("05:00")
  end
  
  it "is invalid if work starts outside work hours" do
    lambda {
      nightly_charge @five_am, @six_pm
    }.must_raise StandardError
   end

  it "is invalid if work ends outside work hours" do   
    lambda {
      nightly_charge @three_am, @five_am
    }.must_raise StandardError
  end

end

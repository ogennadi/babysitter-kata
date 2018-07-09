require "minitest/autorun"
require "time"


class Babysitter
  SB_RATE = 12
  BEDTIME = 21
  
  # Returns the charge for working from START_TIME to END_TIME.
  #
  # START_TIME and END_TIME must be between the working hours, and START_TIME
  # must come before END_TIME.
  def nightly_charge(start_time, end_time)
    adjusted_start = (start_time + 7) % 24
    adjusted_end   = (end_time   + 7) % 24
    
    if adjusted_start  > 11
      raise "Started before 5:00PM"
    end

    if adjusted_end  > 11
      raise "Ended after 4:00AM"
    end


    if adjusted_start > adjusted_end
      raise "Start time occurs after the end time"
    end

    12
  end
end







describe "The nightly charge" do
  before do
    @bs = Babysitter.new
    
    @three_am   = 3
    @six_pm     = 18
    @five_am    = 5

    @sb_rate = Babysitter::SB_RATE
    @bedtime = Babysitter::BEDTIME
  end
  
  it "is invalid if work starts outside work hours" do
    lambda {
      @bs.nightly_charge @five_am, @six_pm
    }.must_raise StandardError
   end

  it "is invalid if work ends outside work hours" do   
    lambda {
      @bs.nightly_charge @three_am, @five_am
    }.must_raise StandardError
  end

  it "is invalid if end time comes before start time" do
    lambda {
      @bs.nightly_charge @three_am, @six_pm
    }.must_raise StandardError
  end

  it "Should pay SB rate if work starts and ends by bedtime" do
    s = @bedtime - 2
    e = @bedtime - 1
    
    @bs.nightly_charge(s, e).must_equal @sb_rate*(e-s)
  end
end

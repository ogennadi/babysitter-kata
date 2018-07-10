require "minitest/autorun"
require "time"


class Babysitter
  SB_RATE = 12
  BM_RATE = 8
  ME_RATE = 16

  BEDTIME  = 21
  MIDNIGHT = 24
  WORK_END = 4
  
  # Returns the charge for working from START_TIME to END_TIME.
  #
  # START_TIME and END_TIME must be between the working hours, and START_TIME
  # must come before END_TIME.
  def nightly_charge(start_time, end_time)
    if adjusted(start_time) > 11
      raise "Started before 5:00PM"
    end

    if adjusted(end_time) > 11
      raise "Ended after 4:00AM"
    end

    if adjusted(start_time) > adjusted(end_time)
      raise "Start time occurs after the end time"
    end

    if adjusted(start_time) < adjusted(BEDTIME) &&
       adjusted(end_time)   <= adjusted(BEDTIME)
      (adjusted(end_time) - adjusted(start_time))* SB_RATE
    elsif adjusted(start_time) < adjusted(BEDTIME) &&
          adjusted(end_time)   <= adjusted(MIDNIGHT)
      (adjusted(BEDTIME) - adjusted(start_time)) * SB_RATE +
      (adjusted(end_time) - adjusted(BEDTIME))   * BM_RATE  
    end
  end


  private
  def adjusted(hour)
    (hour + 7) % 24
  end
end







describe "The nightly charge" do
  before do
    @bs = Babysitter.new
    
    @three_am   = 3
    @six_pm     = 18
    @five_am    = 5

    @sb_rate = Babysitter::SB_RATE
    @bm_rate = Babysitter::BM_RATE
    @bedtime = Babysitter::BEDTIME
    @midnight = 24
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

  it "Should pay SB and BM rates if work starts before bedtime and ends after bedtime but before midnight" do
    s = @bedtime - 1
    e = @midnight

    @bs.nightly_charge(s, e).must_equal @sb_rate + (@midnight - @bedtime)*@bm_rate
  end
end

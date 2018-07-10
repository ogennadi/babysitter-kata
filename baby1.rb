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

    start = adjusted(start_time)
    stop  = adjusted(end_time)
    bed   = adjusted(BEDTIME)
    mid   = adjusted(MIDNIGHT)


    if start > 11
      raise "Started before 5:00PM"
    end

    if stop > 11
      raise "Ended after 4:00AM"
    end

    if start > stop
      raise "Start time occurs after the end time"
    end

    if start < bed && stop   <= bed
      (stop - start)*SB_RATE
    elsif start < bed && stop   <= mid
      (bed - start)*SB_RATE + (stop - bed)*BM_RATE
    elsif start < mid && stop   <= mid
      (stop - start)*BM_RATE
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
    @midnight = Babysitter::MIDNIGHT
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

  it "Should pay BM rates if work starts and ends after bedtime and before midnight" do
    s = @bedtime
    e = @midnight

    @bs.nightly_charge(s, e).must_equal (e-s)*@bm_rate
  end
end

require "minitest/autorun"

class Babysitter
  SB_RATE = 12
  BM_RATE = 8
  ME_RATE = 16

  WORK_START = 17
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
    work_end = adjusted(WORK_END)

    raise "Started before 5:00PM" if start > work_end
    raise "Ended after 4:00AM"    if stop > work_end
    raise "Start time occurs after the end time"    if start > stop

    if start < bed && stop   <= bed
      (stop - start)*SB_RATE
    elsif start < bed && stop   <= mid
      (bed - start)*SB_RATE + (stop - bed)*BM_RATE
    elsif start < mid && stop   <= mid
      (stop - start)*BM_RATE
    elsif start < bed && stop > mid
      (bed - start)*SB_RATE + (mid - bed)*BM_RATE + (stop - mid)*ME_RATE
    elsif start < mid && stop > mid
      (mid - start)*BM_RATE + (stop - mid)*ME_RATE
    elsif start < work_end && stop <= work_end
      (stop - start)*ME_RATE
    else
      raise "invalid rate"
    end
  end


  private
  # Adjust HOUR to a 24-hour clock where midnight is at WORK_START
  def adjusted(hour)
    (hour + (24 - WORK_START)) % 24
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
    @me_rate = Babysitter::ME_RATE
    
    @bedtime = Babysitter::BEDTIME
    @midnight = Babysitter::MIDNIGHT
    @work_end = Babysitter::WORK_END
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

    @bs.nightly_charge(s, e).must_equal @sb_rate + (e - @bedtime)*@bm_rate
  end

  it "Should pay BM rates if work starts and ends after bedtime and before midnight" do
    s = @bedtime
    e = @midnight

    @bs.nightly_charge(s, e).must_equal (e-s)*@bm_rate
  end

  it "Should pay SB, BM, ME rates if work starts before bedtime and ends after midnight" do
  s = @bedtime - 1
  e = @midnight + 1

  @bs.nightly_charge(s, e).must_equal @sb_rate +
    (@midnight - @bedtime)*@bm_rate +
    @me_rate
  end

  it "Should pay BM and ME rates if work starts after bedtime but before midnight, and ends after midnight" do
    s = @midnight - 1
    e = @work_end

    @bs.nightly_charge(s, e).must_equal @bm_rate + @work_end*@me_rate
  end

  it "Should pay ME rate if work starts and ends after midnight" do
    s = @work_end - 1
    e = @work_end

    @bs.nightly_charge(s, e).must_equal (e-s)*@me_rate
  end
end

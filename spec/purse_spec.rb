require File.join(File.dirname(__FILE__), 'spec_helper')

include Money

describe Purse do
  before(:each) do
    @purse = Purse.new
  end
  
  it "should complain if you try to deposit something that isn't valid money" do
    lambda { @purse.deposit(['foo']) }.should raise_error(RuntimeError, 'Invalid money')
  end
  
  it "should let you know when there isn't any change in the purse" do
    @purse.has_coins?.should be_false
  end
  
  context "with one of each deposited" do
    before(:each) do
      @purse.deposit [DOLLAR, QUARTER, NICKEL, DIME]
    end
    
    it "should clear all deposited money" do
      @purse.empty.should == [DOLLAR, QUARTER, NICKEL, DIME]
      @purse.empty.should == []
    end
  
    it "should allow withdrawing quarters, dimes, and nickels" do
      {'quarter' => QUARTER, 'dime' => DIME, 'nickel' => NICKEL}.each do |denomination, coin|
        @purse.send("withdraw_#{denomination}".to_sym).should == coin
      end
    end
    
    it "should blow up if you try to withdraw money when we've run out of that kind" do
      @purse.withdraw_quarter
      lambda { @purse.withdraw_quarter }.should raise_error(RuntimeError, 'No more of that denomination')
    end
  end
end
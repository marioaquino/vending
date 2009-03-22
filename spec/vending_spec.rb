require File.join(File.dirname(__FILE__), 'spec_helper')

describe "VendingMachine initialization" do
  it "should be invalid without a service password" do
    lambda {VendingMachine.new}.should raise_an_error
  end
  
  it "should be valid with a service password" do
    lambda {VendingMachine.new :secret}.should_not raise_an_error
  end
end

describe "VendingMachine service" do
  before(:each) do
    @vender = VendingMachine.new :secret
  end
  
  it "should start with an empty purse by default" do
    @vender.exact_change_warning?.should be_true
  end
  
  it "should require the password to be serviced" do
    lambda {@vender.service}.should raise_an_error(ArgumentError, 'Invalid password')
  end
  
  it "should not allow stocking unless the machine is being serviced" do
    lambda {@vender.stock_a_with :Doritos}.should raise_an_error(RuntimeError, 
      'Invalid while machine not being serviced')
  end
  
  # it "should allow initialization with some amount of coins" do
  #   vender = VendingMachine.new Money::QUARTER, Money::DIME, Money::NICKEL
  #   vender.exact_change_warning?.should be_false
  # end
  
  # it "should not allow initialization with bogus values" do
  #     lambda { VendingMachine.new :Quarter}.should raise_an_error
  #   end
  
  # it "should fix the price for items in specific vending columns" do
  #   @vender.column_a_price.should == 65
  #   @vender.column_b_price.should == 100
  #   @vender.column_c_price.should == 150
  # end
  
  it "should not allow sales while the machine is being serviced"
end

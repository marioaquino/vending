require File.join(File.dirname(__FILE__), 'spec_helper')

include Money

describe VendingMode do
  
  before(:each) do
    @vending = Object.new.extend(VendingMode)
  end
  context "accepting money" do
    it "should have an empty coin return if no money has been added" do
      @vending.coin_return.should be_empty
    end
  
    it "should accept money and display amount added" do
      @vending.add_money(QUARTER)
      @vending.money_added.should == 25
    end
  
    it "should correctly keep track of the amount of money added over successive adds" do
      [DOLLAR, QUARTER, DIME, NICKEL].each {|coin| @vending.add_money coin}
      @vending.money_added.should == 140
    end
  
    it "should return money added when a sale is cancelled" do
      [QUARTER, DIME ].each {|coin| @vending.add_money coin}
      @vending.cancel
      @vending.coin_return.should include(QUARTER, DIME)
    end
  
    it "should show no money added after a sale is cancelled" do
      @vending.add_money QUARTER
      @vending.cancel
      @vending.money_added.should == 0
    end
  end

  context "during sales" do

    before(:each) do
      @purse = []
    end
    
    def stub_purse_for(column, return_value)
      @vending.should_receive(:purse).and_return(@purse)
      @vending.should_receive(:dispense).with(column).and_return(return_value)  
    end
    
    it "should dispense an item from the A row if you deposit 65 cents and select A" do
      stub_purse_for :a, :Doritos
      [QUARTER, QUARTER, DIME, NICKEL].each {|coin| @vending.add_money coin}
      @vending.select(:a).should == :Doritos
      @vending.money_added.should == 0
      @purse.should include(QUARTER, QUARTER, DIME, NICKEL)
    end

    it "should dispense an item from B row if you deposit 1 dollar and select B " do
      stub_purse_for :b, :DingDongs
      @vending.add_money DOLLAR
      @vending.select(:b).should == :DingDongs
      @vending.money_added.should == 0
      @purse.should include(DOLLAR)
    end
    
  end
end
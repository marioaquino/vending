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
    it "should dispense an item from the A column if you deposit 65 cents and select A" do
      do_test_for_column :a, :Doritos, QUARTER, QUARTER, DIME, NICKEL
    end

    it "should dispense an item from B column if you deposit 1 dollar and select B" do
      do_test_for_column :b, :DingDongs, DOLLAR
    end
    
    it "should dispense an item from column C if you deposit 1 dollar and 50 cents and select C" do
      do_test_for_column :c, :MicrowaveHamburger, DOLLAR, QUARTER, QUARTER
    end
    
    it "should return change if more than the sale price was added" do
      purse = mock_purse DOLLAR
      {:withdraw_quarter => QUARTER, :withdraw_dime => DIME}.each_pair do |method, return_value|
        purse.should_receive(method).and_return(return_value)
      end
      @vending.should_receive(:purse).any_number_of_times.and_return(purse)
      @vending.should_receive(:dispense).with(:a).and_return(:Doritos)  
      
      @vending.add_money DOLLAR
      @vending.select(:a)
      @vending.dispensary.should include(:Doritos)
      @vending.coin_return.should include(QUARTER, DIME)
    end
    
    def mock_purse(*money)
      purse = mock("purse")
      purse.should_receive(:deposit).with(money) {|money_arr| money_arr.clear}
      purse
    end

    def do_test_for_column(column, product, *money)
      @vending.should_receive(:purse).and_return(mock_purse money)
      @vending.should_receive(:dispense).with(column).and_return(product)  
      money.each {|denomination| @vending.add_money denomination}
      @vending.select(column)
      @vending.dispensary.should include(product)
      @vending.money_added.should == 0
    end
  end
end
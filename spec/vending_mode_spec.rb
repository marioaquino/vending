require File.join(File.dirname(__FILE__), 'spec_helper')

describe VendingMode do
  
  before(:each) do
    @vending = Object.new.extend(VendingMode)
  end
  
  it "should have an empty coin return if no money has been added" do
    @vending.coin_return.should be_empty
  end
  
  it "should accept money and display amount added" do
    @vending.add_money(Money::QUARTER)
    @vending.money_added.should == 25
  end
  
  it "should correctly keep track of the amount of money added over successive adds" do
    @vending.add_money(Money::QUARTER)
    @vending.add_money(Money::DIME)
    @vending.add_money(Money::NICKEL)
    @vending.add_money(Money::DOLLAR)
    @vending.money_added.should == 140
  end
  
end
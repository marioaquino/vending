require File.join(File.dirname(__FILE__), 'spec_helper')

include Money

def mock_purse(*money)
  purse = mock("purse")
  purse.should_receive(:deposit).with(money) {|money_arr| money_arr.clear}
  purse
end

def new_supply_bin
  Hash.new { |hash, key| hash[key] = [] }
end

describe VendingMode do
  
  before(:each) do
    @vending = Object.new.extend(VendingMode)
  end
  
  context "ready for vending" do
    it "should go into service mode when the service password is supplied" do
      @vending.should_receive(:valid_password?).with('password').and_return(true)
      @vending.should_receive(:toggle_operation_mode)
      @vending.service 'password'
    end
    
    it "should complain if an invalid service password was supplied" do
      @vending.should_receive(:valid_password?).with('password').and_return(false)
      lambda { @vending.service 'password' }.should raise_error(RuntimeError, 'Invalid service password')
    end
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
    
    def do_test_for_column(column, product, *money)
      @vending.should_receive(:purse).and_return(mock_purse money)
      @vending.should_receive(:dispense).with(column).and_return(product)  
      money.each {|denomination| @vending.add_money denomination}
      @vending.select(column)
      @vending.dispensary.should include(product)
      @vending.money_added.should == 0
    end
    
    it "should throw an exception if insufficient funds have been provided during a sales attempt" do
      {a: '0.65', b: '1.00', c: '1.50'}.each_pair do |column, amount|
        lambda { @vending.select(column) }.should raise_error(RuntimeError, "$#{amount} required for sale")
      end
    end
  end
end

describe ServiceMode do
  
  before(:each) do
    @serv = Object.new.extend(ServiceMode)
  end
  
  it "should store items in columns" do
    supply_bin = new_supply_bin
    @serv.should_receive(:supply_bin).any_number_of_times.and_return(supply_bin)
    doritos = [:Doritos] * 3
    @serv.stock(:a, *doritos)
    supply_bin[:a].should == doritos
  end
  
  it "should have a purse that you can deposit change into" do
    change = [QUARTER, DIME, NICKEL] * 3
    @serv.should_receive(:purse).and_return(mock_purse *change)
    @serv.deposit *change
  end
  
  it "should have a purse that you can empty" do
    purse = mock("purse")
    purse.should_receive(:empty).and_return([DOLLAR, QUARTER, DIME, NICKEL])
    @serv.should_receive(:purse).and_return(purse)
    @serv.empty_bank.should include(DOLLAR, QUARTER, DIME, NICKEL)
  end
  
  it "should support ending the service mode" do
    @serv.should_receive(:toggle_operation_mode)
    @serv.activate_vending
  end
end

describe VendingMachine do
  
  context "ready for operation" do
    
    before(:each) do
      @machine = VendingMachine.new 'password'
    end
    
    it "should not allow service mode operations in vending mode" do
      lambda { @machine.activate_vending }.should raise_error(RuntimeError, 'Invalid vending operation')
    end
    
    it "should not allow vending model operations in service mode" do
      @machine.service 'password'
      lambda { @machine.add_money QUARTER }.should raise_error(RuntimeError, 'Invalid service operation')
    end
    
    it "should display all items for sale" do
      pending
      supply_bin = new_supply_bin
      {a: :Doritos, b: :DingDongs, c: :MicrowaveHamburger}.each_pair do |column, item|
        supply_bin[column].concat([item] * 3)
      end
      @mach.should_receive(:supply_bin).any_number_of_times.and_return(supply_bin)
      @vending.sale_items_by_column.should == supply_bin
    end
    
    it "should show the prices for all sales columns" 
  end
end
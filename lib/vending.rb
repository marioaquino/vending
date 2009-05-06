require 'forwardable'

module Money
  DOLLAR = 100
  QUARTER = 25
  DIME = 10
  NICKEL = 5
end

class VendingMachine
  def initialize(password)
    @password = password
    named_context = Struct.new(:name, :delegate).extend(Forwardable)
    named_context.def_delegators :delegate, :toggle_operation_mode, 
                                 :valid_password?, :supply_bin
    vending_mode = named_context.new('vending', self).extend(VendingMode)
    service_mode = named_context.new('service', self).extend(ServiceMode)
    @context = vending_mode
    @modes = [vending_mode, service_mode]
  end
  
  def method_missing(meth, *args, &blk)
    raise "Invalid #{context.name} operation" unless context.respond_to? meth
    context.send meth, *args, &blk
  end
  
  def sale_items_by_column
    supply_bin.dup
  end
  
  private
  attr_reader :modes, :context
  
  def toggle_operation_mode
    @context = modes.index(context) == 0 ? modes.last : modes.first
  end
  
  def valid_password?(password)
    @password == password
  end
  
  def supply_bin
    @supply_bin ||= Hash.new { |hash, key| hash[key] = [] }
  end
  
end

module VendingMode
  def coin_return
    return_tray
  end
  
  def dispensary
    dispensary_bin
  end
  
  def add_money(amount)
    pre_sale_bin << amount
  end
  
  def money_added
    pre_sale_bin.reduce(0, :+)
  end

  def cancel
    return_tray.concat pre_sale_bin
    pre_sale_bin.clear
  end
  
  def select(column)
    change = money_added - column_prices[column]

    raise format("#{column_price(column)} required for sale") unless change >= 0

    purse.deposit pre_sale_bin
          
    purse_change_methods.each_pair do |coin, withdraw_method|
      while (change >= coin)
        change -= coin
        return_tray << purse.send(withdraw_method)
      end
    end      
    
    dispensary_bin << dispense(column)
  end
  
  def sale_prices_by_column
    prices = column_prices.dup
    prices.each{|col, price| prices[col] = column_price(col)}
  end
  
  def service(password)
    raise 'Invalid service password' unless valid_password?(password)
    toggle_operation_mode
  end

  private
  def column_price(column)
    format('$%.2f', column_prices[column] * 0.01)
  end
  
  def pre_sale_bin
    @pre_sale_bin ||= []
  end
  
  def return_tray
    @coin_return_tray ||= []
  end
  
  def dispensary_bin
    @dispensary_bin ||= []
  end
  
  def column_prices
    {:a => 65, :b => 100, :c => 150}
  end
    
  def purse_change_methods
    {QUARTER => :withdraw_quarter, DIME => :withdraw_dime, NICKEL => :withdraw_nickel}
  end
end

module ServiceMode
  def stock(column, *items)
    supply_bin[column].concat(items)
  end
  
  def deposit(*change)
    purse.deposit(change)
  end
  
  def empty_bank
    purse.empty
  end
  
  def activate_vending
    toggle_operation_mode
  end
end

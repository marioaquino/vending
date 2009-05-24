require 'forwardable'
require 'purse'
require 'money'

class VendingMachine
  def initialize(password)
    @password = password
    named_context = Struct.new(:name, :delegate).extend(Forwardable)
    named_context.def_delegators :delegate, :method_missing
    vending_mode = named_context.new('vending', self).extend(VendingMode)
    service_mode = named_context.new('service', self).extend(ServiceMode)
    @context = vending_mode
    @modes = [vending_mode, service_mode]
    @purse = Purse.new
    @supply_bin = Hash.new { |hash, key| hash[key] = [] }
  end
  
  def sale_items_by_column
    supply_bin.dup
  end
  
  def exact_change_needed?
    purse.has_coins? == false
  end
  
  private
  attr_reader :modes, :context, :supply_bin, :purse
  
  def method_missing(meth, *args, &blk)
    return send(meth, *args, &blk) if (respond_to? meth, true)
    raise "Invalid #{context.name} operation" unless context.respond_to? meth
    context.public_send meth, *args, &blk
  end
    
  def toggle_operation_mode
    @context = modes.index(context) == 0 ? modes.last : modes.first
  end
  
  def valid_password?(password)
    @password == password
  end
    
  def dispense(column)
    supply_bin[column].shift
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
  
  def money_deposited
    monetize pre_sale_cents
  end

  def cancel
    return_tray.concat pre_sale_bin
    pre_sale_bin.clear
  end
  
  def make_selection(column)
    change = pre_sale_cents - column_prices[column]

    raise format("#{column_price(column)} required for sale") unless change >= 0
    
    begin
      purse.deposit pre_sale_bin
          
      purse_change_methods.each_pair do |coin, withdraw_method|
        while (change >= coin)
          change -= coin
          return_tray << purse.send(withdraw_method)
        end
      end      
    
      dispensary_bin << dispense(column)
    rescue CannotMakeChangeError
      return_tray.concat pre_sale_bin
      raise RuntimeError, 'Exact change required'
    ensure
      pre_sale_bin.clear
    end
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
  def pre_sale_cents
    pre_sale_bin.reduce(0, :+)
  end
  
  def column_price(column)
    monetize column_prices[column]
  end
  
  def monetize(value)
    format('$%.2f', value * 0.01)
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
    {Money::QUARTER => :withdraw_quarter, Money::DIME => :withdraw_dime, Money::NICKEL => :withdraw_nickel}
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

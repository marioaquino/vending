class VendingMachine
end

module Money
  DOLLAR = 100
  QUARTER = 25
  DIME = 10
  NICKEL = 5
end

module VendingMode
  def coin_return
    return_tray
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
    if column_prices[column] == money_added
      purse.concat pre_sale_bin
      pre_sale_bin.clear
      dispense(column)
    end
  end
  
  private
  def pre_sale_bin
    @pre_sale_bin ||= []
  end
  
  def return_tray
    @coin_return_tray ||= []
  end
  
  def column_prices
    {a: 65, b: 100, c: 150}
  end
end


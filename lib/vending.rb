class VendingMachine
end

module Money
  def Money.const_missing(key)
    VALUES[key]
  end
  
  # def Money.coin?(value)
  #   COINS.has_value? value
  # end

  private
  VALUES = {DOLLAR: 100, QUARTER: 25, DIME: 10, NICKEL: 5}
  # COINS = VALUES.reject{|key, value| value > QUARTER}
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
  
  def select_a
    if money_added == 65
      purse.concat pre_sale_bin
      pre_sale_bin.clear
      pop(:a)
    end
  end
  
  private
  def pre_sale_bin
    @pre_sale_bin ||= []
  end
  
  def return_tray
    @coin_return_tray ||= []
  end
end


module Money
  def Money.const_missing(key)
    VALUES[key]
  end
 
  def Money.coin?(value)
    COINS.has_value? value
  end
  
  def Money.valid_money?(value)
    VALUES.has_value? value
  end
  
  def Money.token_for(value)
    VALUES.key(value)
  end

  private
  VALUES = {:QUARTER => 25, :DIME => 10, :NICKEL => 5, :DOLLAR => 100}
  COINS = VALUES.reject{|key, value| value > QUARTER}
end
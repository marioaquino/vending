class CannotMakeChangeError < RuntimeError
end

class Purse
  def empty
    change = []
    holder.each_value {|money| change.concat money}
    holder.clear
    change
  end
  
  def has_coins?
    holder.any? {|key, value| holder[key].size > 0 }
  end
  
  def deposit(amounts)
    amounts.each do |amount|
      raise 'Invalid money' unless Money::valid_money? amount
      holder[Money.token_for(amount)] << amount
    end
  end
  
  def withdraw_quarter
    withdraw Money::QUARTER
  end
  
  def withdraw_dime
    withdraw Money::DIME
  end
  
  def withdraw_nickel
    withdraw Money::NICKEL
  end
  
  private
  def holder
    @holder ||= Hash.new {|hash, key| hash[key] = [] }
  end
  
  def withdraw(coin)
    coins = holder[Money.token_for coin]
    raise CannotMakeChangeError, 'No more of that denomination' if coins.empty?
    coins.shift
  end
end

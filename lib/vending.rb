class VendingMachine
  def initialize(password = nil)
    raise "Password must be supplied" if password.nil?
    @password = password
    @purse = Hash.new
    @stock = Hash.new {|hash, key| hash[key] = []}
  end
  
  def exact_change_warning?
    @purse.empty?
  end
  
  def service(password = nil)
    raise ArgumentError.new('Invalid password') unless @password.eql? password
  end

  
end

# module Money
#   def Money.const_missing(key)
#     VALUES[key]
#   end
#   
#   def Money.coin?(value)
#     COINS.has_value? value
#   end
# 
#   private
#   VALUES = {:QUARTER => 25, :DIME => 10, :NICKEL => 5}
#   COINS = VALUES.reject{|key, value| value > QUARTER}
# end


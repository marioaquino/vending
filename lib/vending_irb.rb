require 'vending'

class VendingMachine
  # Added so that the methods for objects of this class can be easily "seen"
  # (given the current context) from irb
  def methods
    public_methods(false) + context.public_methods(false)
  end
end
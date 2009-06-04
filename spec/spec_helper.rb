require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'vending'
require 'ui/notifier'

QUARTER = Money::QUARTER
NICKEL = Money::NICKEL
DIME = Money::DIME
DOLLAR = Money::DOLLAR

Spec::Runner.configure do |config|
  
end

module Spec::Matchers
  alias :raise_an_error :raise_error
end

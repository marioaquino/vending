require File.join(File.dirname(__FILE__), 'spec_helper')

describe StateMachine do
  before(:each) do
    @machine = StateMachine.build do
      sequence :foo, :bar, :baz
      sequence :a, :b, :a
    end
  end
  
  it "should gather states" do
    @machine.states.should have(5).items
  end
  
  it "should have predictable transitions" do
    {:foo => :bar, :bar => :baz, :baz => :foo, :a => :b, :b => :a}.each do |key, val|
      @machine.next(key).should == val
    end
  end
end
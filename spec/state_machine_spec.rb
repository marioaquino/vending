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
    {foo: :bar, bar: :baz, baz: :foo, a: :b, b: :a}.each do |key, val|
      @machine.next(key).should == val
    end
  end
  
  it "should know what its initial state is" do
    @machine.state.should == :foo
  end

  it "should allow multi-option state transitions"
end

describe StateMachine do
  
  it "should support event triggering when a state transition happens" do
    state_callback = nil
    machine = StateMachine.build do
      sequence :foo, :bar => proc{ state_callback = :bar_called}
    end
    machine.trans :bar
    state_callback.should == :bar_called
  end
  
  it "should complain when an illegal state transition is attempted"
end
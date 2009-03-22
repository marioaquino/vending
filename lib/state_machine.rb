module StateMachine
  def StateMachine.build(&block)
    states = States.new
    states.instance_exec(&block)
    states
  end
  
  private
  class States
    def initialize
      @states = {}
    end
    
    def next(state)
      states[state]
    end
    
    attr_reader :states
    def sequence(*states)
      states.each_with_index do|item, index|
        @states[item] ||= states[index + 1]
        @states[item] ||= states[0]
      end
    end
  end
end
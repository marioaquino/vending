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
      @events = Hash.new(proc{})
    end
    
    def next(state)
      states[state]
    end
    
    def trans(state)
      back = @events[state]
      @state = state
      back.call
    end
    
    attr_reader :states, :state
    def sequence(*states)
      states.map! do |item| 
        if item.is_a? Hash
          item = item.to_a.flatten
          @events[item.first] = item.last
          item = item.first
        end
        item
      end
      states.each_with_index do|item, index|
        @states[item] ||= states[index + 1]
        @states[item] ||= states[0]
        @state ||= states[0] # default state first time through
      end
    end
  end
end
require File.join(File.dirname(__FILE__), 'spec_helper')

describe FollowingHook do
  it "should connect callback emitters and observers based on a naming convention" do
    
    observer = Object.new
    callbacks = []

    def observer.method_missing(name, *args)
      callbacks << name
    end

    # emitter = "foo"
    
    class Bar
      def to_s
        p 'bar string'
      end
    end

    emitter = Bar.new
    
    # eval(<<EOF, binding) class Bar
    #   include FollowingHook
    #   following(:to_s) {|sender, args, ret_val|
    #     p 'Fo!!!!!!!!!!!!'
    #     observer.to_s_called
    #   }
    # end
    # EOF)

    
    emitter.to_s
    callbacks.should == [:to_s_called]
  end
end
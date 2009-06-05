# module Notifier
  # Assumes that target has methods matching the keys in callbacks.
  # The values in callbacks should be blocks that will get executed
  # when the corresponding methods on the target object are called.
  # def self.wrap_for_callback(target, callbacks)
  #   callbacks.each do |method_name, value|
  #     target.instance_exec {
  #       original_method = target.method(method_name)
  #       def target.
  #         define_method(method_name) {|*args|
  #           original_method.call(*args)
  #           value.call
  #         }
  #       end
  #     }
  #   end
  # end
#   def subscribe_to(publisher, *methods)
#     me = self
#     methods.each do |method_name|
#       publisher.instance_exec {
#         alias "#{method_name}_without_wrapping".to_sym method_name
#         
#       }
#     end
#   end
# end

module FollowingHook
  module ClassMethods

    private
    def following(*syms, &block)
      syms.each do |sym| # For each symbol
        hook_method = :"__#{sym}__hooked__"
        raise ArgumentError, 'hook already exists' if private_instance_methods.include?(hook_method)
        alias_method hook_method, sym
        private hook_method
        define_method sym do |*args|
          after sym, *args, &block
        end
      end
    end
  end
  
  def after(method, *args)
    yield :method => method, :args => args, :return => send(:"__#{method}__hooked__", *args)
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

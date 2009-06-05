class BinderCreator
  def get
    abc = 123
    binding
  end
end

pr = eval(<<EV, BinderCreator.new.get)
  Object.send :define_method, :something do
  abc
end
EV

p pr.something
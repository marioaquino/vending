# Taken from: http://gist.github.com/116876
class Thing
  def foo(bar, baz:raz)
    puts "#{bar}, #{raz}"
  end
  def foo(bar, hash)
    puts "I like #{hash}"
  end
end
 
t = Thing.new
t.foo("cat", baz:"monkey")
#=> cat, monkey
t.foo("cat", raz:"monkeys")
#=> I like {:raz=>"monkeys"}
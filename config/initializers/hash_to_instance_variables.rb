# coding: UTF-8


# Add a method for converting a hash into a set of instance variables
class Object
  def hash_to_instance_variables(h)
    h.each { |k, v| instance_variable_set "@#{k.to_s}", v }
  end
end

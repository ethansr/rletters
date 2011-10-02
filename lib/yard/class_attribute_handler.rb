
class ClassAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:cattr_accessor)
  handles method_call(:cattr_reader)
  handles method_call(:cattr_writer)
  namespace_only
  
  def process
    push_state(:scope => :class) { super }
  end
end

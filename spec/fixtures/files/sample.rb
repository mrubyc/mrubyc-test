class Sample
  attr_accessor :result
  def do_something(arg)
    @result = arg + still_not_defined_method
  end
  def do_other_thing
    is_to_be_hit()
  end
end

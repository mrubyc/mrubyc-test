class Object
  def to_ss
    if self.class == NilClass
      'nil [NilClass]'
    elsif self == ''
      '[NULL String]'
    elsif self.class.to_s.end_with? "Error"
      "#<#{self.class}: #{self.message}>"
    else
      self.inspect + ' [' + self.class_name + ']'
    end
  end
  def class_name
    case self.class
    when String
      'String'
    when Array
      'Array'
    when FalseClass
      'FalseClass'
    when Integer
      'Integer'
    when Float
      'Float'
    when Hash
      'Hash'
    when Math
     'Math'
    when Mutex
      'Mutex'
    when Numeric
      'Numeric'
    when Object
      case self
      when false
        'FalseClass'
      when true
        'TrueClass'
      else
        'Object'
      end
    when Proc
      'Proc'
    when Range
      'Range'
    when String
      'String'
    when Symbol
      'Symbol'
    when VM
      'VM'
    else
      '[User Defined Class]'
    end
  end
end

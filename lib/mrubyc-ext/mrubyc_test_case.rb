class MrubycTestCase
  def initialize(information)
    @information = information
    $mock ||= Mock.new
    @puts_success_message = true
    @puts_failure_message = true
  end
  def puts_information
    puts
    puts @information[:test_class_name] + '#' + @information[:method_name]
  end
  def success(assertion, expected, actual)
    puts_information
    $success_count += 1
    if @puts_success_message
      puts $colors[:success] + '  assertion : ' + assertion.to_s + $colors[:reset]
      puts $colors[:success] + '  result    : ' + actual.to_ss + $colors[:reset]
    else
      print $colors[:success] + '.' + $colors[:reset]
    end
  end
  def failure(assertion, expected, actual, message)
    puts_information
    $failure_count += 1
    if @puts_failure_message
      puts $colors[:failure] + '  path       : ' + @information[:path].to_s
      puts $colors[:failure] + '  line       : ' + @information[:line].to_s
      puts $colors[:failure] + '  description: ' + @information[:description].to_s
      puts $colors[:failure] + '  ' + message if message
      puts $colors[:failure] + '  assertion  : ' + assertion.to_s + $colors[:reset]
      puts $colors[:failure] + '  expected   : ' + expected.to_ss + $colors[:reset]
      puts $colors[:failure] + '  actual     : ' + actual.to_ss + $colors[:reset]
    else
      print $colors[:failure] + '.' + $colors[:reset]
    end
  end

  def assert_equal(expected, actual, message = nil)
    assertion = :assert_equal
    actual == expected ? success(assertion, expected, actual) : failure(assertion, expected, actual, message)
  end

  def assert_not_equal(expected, actual, message = nil)
    assertion = :assert_not_equal
    actual != expected ? success(assertion, expected, actual) : failure(assertion, expected, actual, message)
  end

  def assert_not_nil(expression, message = nil)
    assertion = :assert_not_nil
    expression != nil ? success(assertion, nil, expression) : failure(assertion, nil, expression, message)
  end

  def assert(expression, message = nil)
    assertion = :assert
    expression ? success(assertion, nil, expression) : failure(assertion, nil, expression, message)
  end

  def assert_true(expression, message = nil)
    assertion = :assert_true
    expression === true ? success(assertion, nil, expression) : failure(assertion, nil, expression, message)
  end

  def assert_false(expression, message = nil)
    assertion = :assert_false
    expression === false ? success(assertion, nil, expression) : failure(assertion, nil, expression, message)
  end

  def assert_in_delta(expected, actual, message = nil, delta = 0.001)
    assertion = :assert_in_delta
    dt = actual - expected
    if -delta <= dt && dt <= delta
      success(assertion, expected, actual)
    else
      failure(assertion, expected, actual, message)
    end
  end

  def self.description(text)
  end
  def self.desc(text)
  end
  def setup
  end
  def teardown
  end
  def stub(object)
    object
  end
  def check_mock
    $mock.expected.keys.each do |key|
      $mock.actual[key] = 0 unless $mock.actual[key]
      if $mock.expected[key] > $mock.actual[key]
        failure(:mock, $mock.expected[key], $mock.actual[key], key.to_s + ' shoud have been called at least expected times')
      else
        success(:mock, $mock.expected[key], $mock.actual[key])
      end
    end
  end
end

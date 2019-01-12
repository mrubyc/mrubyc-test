class SampleTest < MrubycTestCase

  # setup() will be invoked before each test case
  def setup
    @string = 'Microcontroller is fun?'
  end

  # teardown() will be invoked before each test case
  def teardown
    # for some technical reasons, it is recommended to reset instance variables by your self
    @string = nil
  end

  # you can and should write some description at just before test case
  description 'replacememt method of String class'
  def string_tr_case
    @string.tr!('?', '!')
    assert_equal 'Microcontroller is fun!', @string
  end

  # desc is an alias of description
  desc 'stab test sample'
  def stab_case
    sample_obj = Sample.new
    stub(sample_obj).still_not_defined_method { " Yes, it is!" }
    sample_obj.do_something(@string)
    assert_equal 'Microcontroller is fun? Yes, it is!', sample_obj.result
  end

  desc 'mock test sample'
  def mock_case
    sample_obj = Sample.new
    mock(sample_obj).is_to_be_hit
    sample_obj.do_other_thing
  end

end


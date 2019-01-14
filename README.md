# mrubyc-test

mrubyc-test is an unit test framework for [mruby/c](https://github.com/mrubyc/mrubyc), supporting basic assertions, stub and mock.

## Acknowledgements

The API design and implementation of this gem is greatly inspired by [test-unit](https://github.com/test-unit/test-unit). Thank the great work.

## Features

- Tests are applicable to mruby code. C code will not be covered
- Tests will run on your PC (POSIX) hereby you can write *business logic* with mruby/c apart from C API matters like microcontroler peripherals
- Simple assertions ... enough for almost firmware development though, I will increase the number of assertion
- Stub ... You can write your mruby code without peripheral implementation by C
- Mock ... You can call any method sill doesn't exist
- The implementation of your application and test code will be analyzed by CRuby program, then comlpiled into mruby byte code and executed on mruby/c VM

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mrubyc-test'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mrubyc-test

## Usage

Assuming you are using [mrubyc-utils](https://github.com/hasumikin/mrubyc-utils) to manage your project and [rbenv](https://github.com/rbenv/rbenv) to manage Ruby versions.
This means you have `.mrubycconfig` file in your top directory.

Besides, you have to locate mruby model files that are the target of testing like `mrblib/models/class_name.rb`

This is an example of ESP32 project:

```
~/your_project $ tree
.
├── .mrubycconfig                # Created by mrubyc-utils
├── Makefile
├── build
├── components
├── main
├── mrblib
│      └── models               # Place your model class files here
│            ├── class_name.rb  # The testing target `ClassName`
│            └── my_class.rb    # The testing target `MyClass`
│      └── tasks
│            ├── main.rb        # Loop script isn't covered by mrubyc-test. use mrubyc-debugger
│            └── sub.rb         # Loop script isn't covered by mrubyc-test. use mrubyc-debugger
└── sdkconfig
```

In the same directory:

    $ mrubyc-test init

Then, some directories and files will be created in your project.
Now you can run test because a sample test code was also created.

    $ mrubyc-test test

You should get some assertion faulures.
Take a look at `test/sample_test.rb` to handle the failures and know how to write your own test.

### Asserions

```ruby
def assertions
  my_var = 1
  assert_equal     1, my_var  # => success
  assert_not_equal 2, my_var  # => success
  assert_not_nil   my_var     # => success
end
```

### Stubs

Assuming you have a model file at `mrblib/models/sample.rb`

```ruby
class Sample
  def do_something
    attr_accessor :result
    def do_something(arg)
      @result = arg + still_not_defined_method
    end
  end
end
```

Then you can test `#do_something` method without having `#still_not_defind_method` like this:

```ruby
def stub_case
  sample_obj = Sample.new
  stub(sample_obj).still_not_defined_method { ", so we are nice" }
  sample_obj.do_something("Ruby is nice")
  assert_equal 'Ruby is nice, so we are nice', sample_obj.result
end
```

### Mocks

`mrblib/models/sample.rb` looks like this time:

```ruby
class Sample
  def do_other_thing
    is_to_be_hit()
  end
end
```

You can test whether `#is_to_be_hit` method will be called:

```ruby
def mock_case
  sample_obj = Sample.new
  mock(sample_obj).is_to_be_hit
  sample_obj.do_other_thing
end
```

## Known problems

- `.ruby-version` should be set to a veriosn of CRuby to use mrubyc-test command although mruby/c developers want to set it like mruby-1.4.1
- You have to write stub or mock test fot all the methods still do not exist otherwise your test won't turn green

## TODO (possibly)

- Better solution of coexistence of CRuby and mruby. May be a kind of wrapper tool or rbenv plugin?
- Assertion against arguments of mock
- Other assertions like LT(<), GTE(>=), include?, ...etc.
- bla bla bla

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hasumikin/mrubyc-test. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mrubyc::Test project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mrubyc-test/blob/master/CODE_OF_CONDUCT.md).

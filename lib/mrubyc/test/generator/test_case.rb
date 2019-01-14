# frozen_string_literal: true

module Mrubyc
  module Test
    module Generator
      class TestCase
        class << self
          def run(attributes)
            test_cases = []
            attributes[:method_locations].each do |klass, methods|
              methods.each do |method|
                if attributes[:description_locations].size > 0
                  found_desc = attributes[:description_locations][klass].find do |hash|
                    hash[:line] == method[:line] -1
                  end
                end
                description = found_desc ? found_desc[:text] : ''
                information = {
                  test_class_name: klass.to_s,
                  method_name: method[:method_name],
                  path: method[:path],
                  line: method[:line],
                  description: description
                }
                stubs = []
                mocks = []
                attributes[:double_method_locations][klass].each do |hash|
                  if hash.keys[0] == method[:method_name]
                    hash[method[:method_name]].each do |double|
                      stub_or_mock = { class_name: double[:class].to_s,
                        instance_variables: nil, # TODO
                        method_name: double[:method_name].to_s,
                        args: double[:args],
                        return_value: double[:block],
                        line: double[:line]
                      }
                      if double[:type] == :stub
                        stubs << stub_or_mock
                      else
                        mocks << stub_or_mock
                      end
                    end
                  end
                end
                test_cases << {
                  information: information,
                  stubs: stubs,
                  mocks: mocks
                }
              end
            end
            test_cases
          end
        end
      end
    end
  end
end

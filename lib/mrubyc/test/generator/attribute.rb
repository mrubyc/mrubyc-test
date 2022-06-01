# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Mrubyc
  module Test
    module Generator
      class Attribute
        class << self
          def run(model_files: [], test_files:)
            # get information from model files(application code)
            model_files.each do |model_file|
              puts "loading #{model_file}"
              load model_file
              class_name = File.basename(model_file, '.rb').camelize
              model_class = if Module.const_defined?(class_name)
                Module.const_get(class_name)
              elsif Module.const_defined?(class_name.upcase)
                Module.const_get(class_name.upcase)
              end
              unless model_class
                # Deprecate 2022-06-01
                #print "\e[33m"
                #puts "[WARN] #{model_file} doesn't have corresponding class `#{class_name}`."
                #print "\e[m"
                next
              end
              model_class.class_eval do
                def method_missing(_method_name, *_args)
                  # do nothing
                end
              end
            end
            # get information from test files
            method_locations = {}
            description_locations = {}
            double_method_locations = {}
            MrubycTestCase.init_class_variables
            test_files.each do |test_file|
              load test_file
              test_class = Module.const_get(File.basename(test_file, '.rb').camelize)
              method_locations.merge!(test_class.class_variable_get(:@@method_locations))
              description_locations.merge!(test_class.class_variable_get(:@@description_locations))
              my_test = test_class.new
              double_method_locations[test_class] = []
              test_class.class_variable_get(:@@added_method_names)[test_class].each do |method_name, _v|
                Mrubyc::Test::Generator::Double.init_double_method_locations
                begin
                  my_test.send(method_name)
                rescue NoMethodError => e
                end
                double_method_locations[test_class] << { method_name => Mrubyc::Test::Generator::Double.class_variable_get(:@@double_method_locations) }
              end
            end
            { method_locations: method_locations,
              description_locations: description_locations,
              double_method_locations: double_method_locations }
          end
        end
      end
    end
  end
end

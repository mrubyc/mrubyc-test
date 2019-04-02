# frozen_string_literal: true

require 'mrubyc/test/generator/double'

class MrubycTestCase
  class << self
    @@description_locations = {}
    def description(text)
      location = caller_locations(1, 1)[0]
      path = location.absolute_path || location.path
      line = location.lineno
      location = {
        text: text,
        path: File.expand_path(path),
        line: line,
      }
      add_description_location(location)
    end
    alias :desc :description

    @@added_method_names = {}
    @@method_locations = {}
    def method_added(name)
      return false if %i(method_missing setup teardown).include?(name)
      # puts "method '#{self}' '#{name}' '#{name.class}' was added"
      added_method_names = (@@added_method_names[self] ||= {})
      stringified_name = name.to_s
      location = caller_locations(1, 1)[0]
      path = location.absolute_path || location.path
      line = location.lineno
      location = {
        method_name: stringified_name,
        path: File.expand_path(path),
        line: line,
      }
      add_method_location(location)
      added_method_names[stringified_name] = true
    end

    def added_method_names
      (@@added_method_names[self] ||= {}).keys
    end

    def init_class_variables
      @@description_locations = {}
      @@method_locations = {}
      @@added_method_names = {}
    end

    private

      def method_locations
        @@method_locations[self] ||= []
      end

      def add_method_location(location)
        method_locations << location
      end

      def description_locations
        @@description_locations[self] ||= []
      end

      def add_description_location(location)
        description_locations << location
      end

  end

  def method_missing(method_name, *args)
    case method_name
    when :stub, :mock
      location = caller_locations(1, 1)[0]
      Mrubyc::Test::Generator::Double.new(method_name, args[0], location)
    end
  end
end


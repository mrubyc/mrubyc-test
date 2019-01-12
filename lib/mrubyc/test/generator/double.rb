# frozen_string_literal: true

module Mrubyc
  module Test
    module Generator
      class Double
        class << self
          def init_double_method_locations
            @@double_method_locations = []
          end
        end

        def initialize(type, object, location)
          @type = type
          @klass = object.class
          @location = location
        end

        def method_missing(method_name, *args)
          @@double_method_locations << {
            type: @type,
            class: @klass,
            method_name: method_name,
            args: args.to_s,
            block: (block_given? ? yield : nil),
            label: @location.label,
            path: @location.absolute_path || @location.path,
            line: @location.lineno
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rufo'
require 'erb'

module Mrubyc
  module Test
    module Generator
      class Script
        class << self
          def run(model_files: [], test_files:, test_cases:, verbose:, method_name_pattern:)
            config = Mrubyc::Test::Config.read
            erb = ERB.new(File.read(File.expand_path('../../../../templates/test.rb.erb', __FILE__)), nil, '-')
            mrubyc_class_dir = File.expand_path('../../../../mrubyc-ext/', __FILE__)
            File.write(File.join(config['test_tmp_dir'], 'test.rb'), Rufo.format(erb.result(binding)))
          end
        end
      end
    end
  end
end

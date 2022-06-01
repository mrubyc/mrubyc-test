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
            test_erb = ERB.new(
              File.read(
                File.expand_path('../../../../templates/test.rb.erb', __FILE__)
              ), trim_mode: '-'
            )
            models_erb = ERB.new(
              File.read(
                File.expand_path('../../../../templates/models.rb.erb', __FILE__)
              ), trim_mode: '-'
            )
            mrubyc_class_dir = File.expand_path('../../../../mrubyc-ext/', __FILE__)
            File.write(File.join(
              config['test_tmp_dir'], 'test.rb'),
              Rufo.format(test_erb.result(binding))
            )
            File.write(File.join(
              config['test_tmp_dir'], 'models.rb'),
              Rufo.format(models_erb.result(binding))
            )
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'erb'
require 'fileutils'

module Mrubyc
  module Test
    class Init
      class << self
        def run
          puts 'Initializing...'
          puts

          puts '  touch .mrubycconfig'
          config = Mrubyc::Test::Config.read(check: false)
          config['test_dir'] = 'test'
          config['test_tmp_dir'] = 'test/tmp'
          puts '  add config to .mrubycconfig'
          Mrubyc::Test::Config.write(config)

          puts '  mikdir -p test/tmp'
          FileUtils.mkdir_p('test/tmp')

          puts '  cp test/sample_main.c'
          erb = ERB.new(File.read(File.expand_path('../../../templates/sample_test.rb.erb', __FILE__)), nil, '-')
          File.write(File.join(config['test_tmp_dir'], 'sample_test.rb'), erb.result(binding))

          puts '  cp test/tmp/main.c'
          erb = ERB.new(File.read(File.expand_path('../../../templates/main.c.erb', __FILE__)), nil, '-')
          File.write(File.join(config['test_tmp_dir'], 'main.c'), erb.result(binding))
        end
      end
    end
  end
end

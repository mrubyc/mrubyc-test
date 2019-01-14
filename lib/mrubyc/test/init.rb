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
          config['mruby_lib_dir'] = 'mrblib'
          puts '  add config to .mrubycconfig'
          Mrubyc::Test::Config.write(config)

          hal_dir = "#{config['test_tmp_dir']}/hal"
          puts "  mikdir -p #{hal_dir}"
          FileUtils.mkdir_p(hal_dir)

          Dir.chdir(hal_dir) do
            puts "  download from https://raw.githubusercontent.com/mrubyc/mrubyc/master/src/hal_posix/hal.h"
            system 'wget https://raw.githubusercontent.com/mrubyc/mrubyc/master/src/hal_posix/hal.h'
            puts "  download from https://raw.githubusercontent.com/mrubyc/mrubyc/master/src/hal_posix/hal.c"
            system 'wget https://raw.githubusercontent.com/mrubyc/mrubyc/master/src/hal_posix/hal.c'
          end


          puts "  mikdir -p #{config['mruby_lib_dir']}/models"
          FileUtils.mkdir_p('test/tmp')

          puts '  cp test/sample_test.rb'
          erb = ERB.new(File.read(File.expand_path('../../../templates/sample_test.rb.erb', __FILE__)), nil, '-')
          File.write(File.join(config['test_dir'], 'sample_test.rb'), erb.result(binding))

          puts '  cp test/tmp/main.c'
          erb = ERB.new(File.read(File.expand_path('../../../templates/main.c.erb', __FILE__)), nil, '-')
          File.write(File.join(config['test_tmp_dir'], 'main.c'), erb.result(binding))

          puts
          puts "\e[32mWelcome to mrubyc-test, the world\'s first TDD tool for mruby/c microcontroller development.\e[37m"
          puts "\e[33m"
          puts 'Caution:'
          puts 'For the time being, mrubyc-test assumes you installed mruby-1.4.1 by rbenv. So you should have `~/.rbenv/versions/mruby-1.4.1/bin.mrbc`'
          puts 'Sorry for the inconvenience. It will be fixed soon!'
          puts "\e[37m"
        end
      end
    end
  end
end

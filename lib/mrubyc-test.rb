# frozen_string_literal: true

require "mrubyc_test_case/mrubyc_test_case"
require "mrubyc/test/version"
require "mrubyc/test/config"
require "mrubyc/test/init"
require "mrubyc/test/generator/attribute"
require "mrubyc/test/generator/test_case"
require "mrubyc/test/generator/script"
require "mrubyc/test/generator/double"
require "thor"

module Mrubyc::Test
  class Error < StandardError; end

  class Tool < Thor
    desc 'init', 'Initialize requirements for unit test of mruby/c. Some directories and files will be created. Note that existing objects may be overridden'
    def init
      Mrubyc::Test::Init.run
    end

    desc 'prepare', 'Create a ruby script that has all the requirements of your test'
    def prepare
      config = Mrubyc::Test::Config.read
      model_files = Dir.glob(File.expand_path(File.join('../../', config['mruby_lib_dir'], 'models', '*.rb'), __FILE__))
      test_files = Dir.glob(File.expand_path(File.join('../../', config['test_dir'], '*.rb'), __FILE__))
      if test_files.size == 0
        puts 'Test not found'
        exit(1)
      end

      # gather attributes from your implementations and tests
      attributes = Mrubyc::Test::Generator::Attribute.run(model_files: model_files, test_files: test_files)

      # convert attributes into tast_cases
      test_cases = Mrubyc::Test::Generator::TestCase.run(attributes)

      # generate a ruby script that will be compiled by mrbc and executed in mruby/c VM
      Mrubyc::Test::Generator::Script.run(model_files: model_files, test_files: test_files, test_cases: test_cases)
    end

    desc 'make', 'compile test script into executable && run it'
    def make
      config = Mrubyc::Test::Config.read
      tmp_dir = File.expand_path(File.join('../../', config['test_tmp_dir']), __FILE__)
      puts "cd #{tmp_dir}"
      puts
      exit_code = 0
      Dir.chdir(tmp_dir) do
        ['~/.rbenv/versions/mruby-1.4.1/bin/mrbc -E -B test test.rb',
         "cc -I ../../#{config['mrubyc_src_dir']} -DMRBC_DEBUG -o test main.c ../../#{config['mrubyc_src_dir']}/*.c ../../#{config['mrubyc_src_dir']}/hal/*.c",
         './test'].each do |cmd|
           puts cmd
           puts
           exit_code = system(cmd) ? 0 : 1
         end
      end
      puts
      puts "cd -"
      puts
      exit(exit_code)
    end

    desc 'test', 'shortcut for `prepare` && `make`'
    def test
      prepare
      make
    end
  end
end


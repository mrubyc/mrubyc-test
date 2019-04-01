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
    default_command :test

    desc 'init', 'Initialize requirements for unit test of mruby/c. Some directories and files will be created. Note that existing objects may be overridden'
    def init
      Mrubyc::Test::Init.run
    end

    desc 'prepare', 'Create a ruby script that has all the requirements of your test'
    def prepare(testfilepath = "")
      config = Mrubyc::Test::Config.read
      model_files = Dir.glob(File.join(Dir.pwd, config['mruby_lib_dir'], 'models', '*.rb'))
      test_path = if testfilepath == ""
        File.join(Dir.pwd, config['test_dir'], "*.rb")
      else
        File.join(Dir.pwd, testfilepath)
      end
      test_files = Dir.glob(test_path)
      if test_files.size == 0
        puts 'Test not found'
        puts 'search path: ' + test_path
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
      tmp_dir = File.join(Dir.pwd, config['test_tmp_dir'])
      puts "cd #{tmp_dir}"
      puts
      exit_code = 0
      pwd = Dir.pwd
      mruby_version = File.read('.ruby-version').gsub("\n", '').chomp
      unless mruby_version.index('mruby')
        puts '.ruby-version doesn\'t set `mruby-x.x.x It is recommended to use https://github.com/hasumikin/mrubyc-utils v0.0.6+`'
        print 'Version name of mruby [mruby-x.x.x]: '
        mruby_version = STDIN.gets.chomp
      end
      FileUtils.mv "#{pwd}/#{config['mrubyc_src_dir']}/hal", "#{pwd}/#{config['mrubyc_src_dir']}/~hal"
      begin
        FileUtils.ln_s "#{pwd}/#{config['test_tmp_dir']}/hal", "#{pwd}/#{config['mrubyc_src_dir']}/hal"
        Dir.chdir(tmp_dir) do
          [
           "ls -l",
           "RBENV_VERSION=#{mruby_version} mrbc -E -B test test.rb",
           "ls -l",
           "cc -Wl,--no-as-needed -lm -I #{pwd}/#{config['mrubyc_src_dir']} -DMRBC_DEBUG -DMRBC_USE_MATH=1 -o test main.c #{pwd}/#{config['mrubyc_src_dir']}/*.c #{pwd}/#{config['mrubyc_src_dir']}/hal/*.c",
           "ls -l",
           './test'].each do |cmd|
             puts cmd
             puts
             exit_code = system(cmd) ? 0 : 1
           end
          puts
          puts "cd -"
          puts
        end
      ensure
        FileUtils.rm "#{pwd}/#{config['mrubyc_src_dir']}/hal"
        FileUtils.mv "#{pwd}/#{config['mrubyc_src_dir']}/~hal", "#{pwd}/#{config['mrubyc_src_dir']}/hal"
      end
      exit(exit_code)
    end

    desc 'test', 'shortcut for `prepare` && `make`'
    def test(testfilepath = "test/*.rb")
    pp testfilepath
      prepare(testfilepath)
      make
    end

    desc "version", "print the version"
    def version
      puts "mrubyc-test v#{Mrubyc::Test::VERSION}"
    end

  end
end

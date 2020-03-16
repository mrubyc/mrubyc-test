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

    no_commands do
      def prepare(test_files, verbose, method_name_pattern)
        config = Mrubyc::Test::Config.read
        model_files = Dir.glob(File.join(Dir.pwd, config['mruby_lib_dir'], 'models', '*.rb'))

        # gather attributes from your implementations and tests
        attributes = Mrubyc::Test::Generator::Attribute.run(model_files: model_files, test_files: test_files)

        # convert attributes into tast_cases
        test_cases = Mrubyc::Test::Generator::TestCase.run(attributes)

        # generate a ruby script that will be compiled by mrbc and executed in mruby/c VM
        Mrubyc::Test::Generator::Script.run(model_files: model_files, test_files: test_files, test_cases: test_cases, verbose: verbose, method_name_pattern: method_name_pattern)
      end

      def make
        config = Mrubyc::Test::Config.read
        tmp_dir = File.join(Dir.pwd, config['test_tmp_dir'])
        puts "cd #{tmp_dir}"
        puts
        exit_code = 0
        pwd = Dir.pwd
        mruby_version = File.read('.ruby-version').gsub("\n", '').chomp
        unless mruby_version.index('mruby')
          puts '.ruby-version doesn\'t set `mruby-x.x.x It is recommended to use the latest version of https://github.com/hasumikin/mrubyc-utils`'
          print 'You can specify the version name of mruby [mruby-x.x.x]: '
          mruby_version = STDIN.gets.chomp
        end
        hal_path = "#{pwd}/#{config['mrubyc_src_dir']}/hal"
        hal_bak_path = "#{pwd}/#{config['mrubyc_src_dir']}/~hal"
        FileUtils.mv(hal_path, hal_bak_path) if FileTest.exist?(hal_path)
        begin
          FileUtils.ln_s "#{pwd}/#{config['test_tmp_dir']}/hal", "#{pwd}/#{config['mrubyc_src_dir']}/hal"
          Dir.chdir(tmp_dir) do
            [
             "RBENV_VERSION=#{mruby_version} mrbc -E -B test test.rb",
             "cc #{ENV["CFLAGS"]} #{ENV["LDFLAGS"]} -I #{pwd}/#{config['mrubyc_src_dir']} -o test main.c #{pwd}/#{config['mrubyc_src_dir']}/*.c #{pwd}/#{config['mrubyc_src_dir']}/hal/*.c",
             "./test"].each do |cmd|
               puts cmd
               puts
               exit_code = system(cmd) ? 0 : 1
               exit(exit_code) if exit_code > 0
             end
          end
        ensure
          FileUtils.rm hal_path
          FileUtils.mv(hal_bak_path, hal_path) if FileTest.exist?(hal_bak_path)
        end
      end

      def init_env
        ENV["CFLAGS"] = "-std=gnu99 -DMRBC_DEBUG -DMRBC_USE_MATH=1 -Wall #{ENV["CFLAGS"]}"
        ENV["LDFLAGS"] = "-Wl,--no-as-needed -lm #{ENV["LDFLAGS"]}"
      end

    end

    desc 'test', '[Default command] Execute test. You can specify a test file like `mrubyc-test test test/array_test.rb`'
    option :every, type: :numeric, default: 10, aliases: "-e", banner: "NUMBER - To avoid Out of Memory, test will be devided up to every specified NUMBER of xxx_test.rb files"
    option :verbose, type: :boolean, default: false, aliases: "-v", banner: "[true/false] - Show test result verbosely"
    option :name, type: :string, aliases: "-n", banner: "NAME - Specify the NAME of tests you want to run. If you write --name='/PATTERN/', it will be processed as a regular expression. It must be single-quoted and doubled-backslash. eg) --name='/a\\\\db/' will create Regexp object `/a\\db/` and match strings like `a1b`"
    def test(testfilepath = "test/*.rb")
      init_env
      method_name_pattern = (%r{\A/(.*)/\Z} =~ options[:name] ? Regexp.new($1) : options[:name])
      test_path = if testfilepath == ""
        File.join(Dir.pwd, config['test_dir'], "*.rb")
      else
        File.join(Dir.pwd, testfilepath)
      end
      Dir.glob(test_path).each_slice(options[:every]) do |test_files|
        prepare(test_files, options[:verbose], method_name_pattern)
        make
      end
    end

    desc "version", "Print the version"
    def version
      puts "mrubyc-test v#{Mrubyc::Test::VERSION}"
    end

    def help(arg = nil)
      super(arg)
      init_env
      if arg == "test"
        puts
        puts "Default environment variables you can change:"
        puts "  CFLAGS='#{ENV['CFLAGS']}'"
        puts "  LDFLAGS='#{ENV['LDFLAGS']}'"
        puts
      end
      exit if arg
      puts "\e[33m  Note:"
      puts '  It is recommended to use mrubyc-utils as a wrapper of this gem'
      puts '  see https://github.com/hasumikin/mrubyc-utils#wrapper-of-gem-mrubyc-test-and-mrubyc-debugger'
      puts "\e[0m"
    end

  end
end

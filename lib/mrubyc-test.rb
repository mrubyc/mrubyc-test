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
        attributes = Mrubyc::Test::Generator::Attribute.run(
          model_files: model_files,
          test_files: test_files
        )
        # convert attributes into tast_cases
        test_cases = Mrubyc::Test::Generator::TestCase.run(attributes)
        # generate a ruby script that will be compiled by mrbc and executed in mruby/c VM
        Mrubyc::Test::Generator::Script.run(
          model_files: model_files,
          test_files: test_files,
          test_cases: test_cases,
          verbose: verbose,
          method_name_pattern: method_name_pattern
        )
      end

      def make(mrbc_path)
        config = Mrubyc::Test::Config.read
        tmp_dir = File.join(Dir.pwd, config['test_tmp_dir'])
        puts "cd #{tmp_dir}"
        puts
        pwd = Dir.pwd
        hal_path = "#{pwd}/#{config['mrubyc_src_dir']}/hal"
        hal_bak_path = "#{pwd}/#{config['mrubyc_src_dir']}/~hal"
        FileUtils.rm_rf hal_bak_path
        FileUtils.mv(hal_path, hal_bak_path) if FileTest.exist?(hal_path)
        exit_code = 0
        cc = ENV['CC'].to_s.length > 0 ? ENV['CC'] : "gcc"
        qemu = ENV['QEMU']
        begin
          FileUtils.ln_sf "#{pwd}/#{config['test_tmp_dir']}/hal", "#{pwd}/#{config['mrubyc_src_dir']}/hal"
          Dir.chdir(tmp_dir) do
            [
              "#{mrbc_path} -B test test.rb",
              "#{mrbc_path} -B models models.rb",
              "#{cc} -O0 -g3 -Wall -I #{pwd}/#{config['mrubyc_src_dir']} -static -o test main.c #{pwd}/#{config['mrubyc_src_dir']}/*.c #{pwd}/#{config['mrubyc_src_dir']}/hal/*.c -DMRBC_INT64 -DMAX_SYMBOLS_COUNT=1000 -DMRBC_USE_MATH=1 -DMRBC_USE_HAL_POSIX #{ENV["CFLAGS"]} #{ENV["LDFLAGS"]}",
              "#{qemu} ./test"
            ].each do |cmd|
              puts cmd
              puts
              exit_code = 1 unless Kernel.system(cmd)
            end
          end
        ensure
          FileUtils.rm hal_path
          FileUtils.mv(hal_bak_path, hal_path) if FileTest.exist?(hal_bak_path)
        end
        return exit_code
      end

      def init_env
        ENV["CFLAGS"] = "-std=gnu99 -Wall #{ENV["CFLAGS"]}"
        ENV["LDFLAGS"] = "-lm #{ENV["LDFLAGS"]}"
      end

    end

    desc 'test', <<~DESC
      [Default command]
      Execute test. You can specify a test file like
      `mrubyc-test test test/array_test.rb`'
    DESC
    option :every, type: :numeric, default: 10, aliases: "-e",
      banner: <<~DESC.chomp
        NUMBER
               To avoid Out of Memory, test will be devided up to
               every specified NUMBER of xxx_test.rb files
      DESC
    option :verbose, type: :boolean, default: false, aliases: "-v",
      banner: "[true/false] - Show test result verbosely"
    option :name, type: :string, aliases: "-n",
      banner: <<~DESC.chomp
        NAME
               Specify the NAME of tests you want to run. If you
               write --name='/PATTERN/', it will be processed as a regular
               expression. It must be single-quoted and doubled-backslash.
               eg) --name='/a\\\\db/' will create Regexp object `/a\\db/`
                   and match strings like `a1b`
      DESC
    option :mrbc_path, type: :string, aliases: "-p",
      banner: <<~DESC.chomp
        PATH
               Specify the path to mrbc.
               eg: /home/hoge/mruby/build/host/bin/mrbc
               RBENV_VERSION will be ignored if you specify this option.
      DESC
    def test(testfilepath = "")
      Mrubyc::Test::Init.init_main_c
      init_env
      config = Mrubyc::Test::Config.read
      method_name_pattern = (%r{\A/(.*)/\Z} =~ options[:name] ? Regexp.new($1) : options[:name])
      test_path = if testfilepath == ""
        File.join(Dir.pwd, config['test_dir'], "*.rb")
      else
        File.join(Dir.pwd, testfilepath)
      end
      mrbc_path = options[:mrbc_path] || config['mrbc_path']
      unless mrbc_path
        mruby_version = File.read('.ruby-version').gsub("\n", '').chomp
        unless mruby_version.index('mruby')
          puts '.ruby-version doesn\'t set `mruby-x.x.x It is recommended to use the latest version of https://github.com/hasumikin/mrubyc-utils`'
          print 'You can specify the version name of mruby [mruby-x.x.x]: '
          mruby_version = STDIN.gets.chomp
        end
        "RBENV_VERSION=#{mruby_version} mrbc"
      end
      exit_code = 0
      Dir.glob(test_path).each_slice(options[:every]) do |test_files|
        prepare(test_files, options[:verbose], method_name_pattern)
        exit_code += make(mrbc_path)
      end
      if exit_code > 0
        puts "\e[31mFinished with error(s)\e[0m"
        exit 1
      end
      puts "\e[32mFinished without error\e[0m"
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

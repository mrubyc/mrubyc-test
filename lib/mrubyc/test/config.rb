# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module Mrubyc
  module Test
    class Config
      class << self
        def read(check: true)
          config = YAML.load_file(mrubycfile)
          if check
            if !config || config == [] || !config['test_dir']
              raise 'Check if `Mrubycfile or .mrubycconfig` exists.'
            end
          end
          if config && ENV['MRUBYCFILE']
            config.each do |k, v|
              if v && k != "mrbc_path"
                config[k] = File.join File.dirname(ENV['MRUBYCFILE']), v
              end
            end
          end
          config || {}
        end

        def write(config)
          File.open(mrubycfile, 'r+') do |file|
            file.write(config.to_yaml)
          end
        end

        def mrubycfile
          if ENV['MRUBYCFILE']
            ENV['MRUBYCFILE']
          elsif File.exist? 'Mrubycfile'
            'Mrubycfile'
          elsif File.exist? '.mrubycconfig'
            '.mrubycconfig'
          else
            FileUtils.touch 'Mrubycfile'
            'Mrubycfile'
          end
        end
      end
    end
  end
end

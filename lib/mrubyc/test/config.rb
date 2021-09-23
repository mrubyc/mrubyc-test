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
          config || {}
        end

        def write(config)
          File.open(mrubycfile, 'r+') do |file|
            file.write(config.to_yaml)
          end
        end

        def mrubycfile
          if File.exists? 'Mrubycfile'
            'Mrubycfile'
          elsif  File.exists? '.mrubycconfig'
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

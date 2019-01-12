# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module Mrubyc
  module Test
    class Config
      class << self
        def read(check: true)
          FileUtils.touch('.mrubycconfig')
          config = YAML.load_file('.mrubycconfig')
          if check
            if !config || config == [] || !config['test_dir']
              raise 'Check if `.mrubycconfig` exists.'
            end
          end
          config || {}
        end

        def write(config)
          File.open('.mrubycconfig', 'r+') do |file|
            file.write(config.to_yaml)
          end
        end
      end
    end
  end
end

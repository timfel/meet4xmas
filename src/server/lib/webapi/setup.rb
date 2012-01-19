# require all files in this directory
Dir.glob(File.dirname(__FILE__) + '/*.rb', &method(:require))
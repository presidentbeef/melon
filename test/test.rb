require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/melon'

Dir[File.join(__dir__, "*.rb")].each do |f|
  require_relative f
end

require "yaml"
require "json"

class Hash
  alias :f :fetch
end

require_relative 'config'
require_relative 'lib'
include Lib

require "cf/interface/version"
require "cf/interface/interface"

module CF
  module Interface
    def self.new(message_bus)
      ::CF::Interface::Interface.new(message_bus)
    end
  end
end

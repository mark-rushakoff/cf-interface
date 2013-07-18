require "cf/interface/version"
require "cf/interface/interface"

module CF
  module Interface
    def self.new
      ::CF::Interface::Interface.new
    end
  end
end

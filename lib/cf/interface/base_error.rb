module CF::Interface
  class BaseError < ::RuntimeError
    attr_reader :original

    def initialize(message, original = $!)
      super(message)
      @original = original
    end
  end
end

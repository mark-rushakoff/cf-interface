module CF::Interface
  class BaseError < ::RuntimeError
    def initialize(message, original = $!)
      super(message)
      @original = original
    end
  end
end

module Gingham
  class MoveFrame
    attr_accessor :index, :actors

    def initialize(index, actors)
      @index = index
      # deep_copy actors
      @actors = Marshal.load Marshal.dump(actors)
    end
  end
end

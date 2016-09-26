module Gingham
  class Position
    attr_accessor :x, :y, :z

    def initialize(x, y, z)
      @x, @y, @z = x, y, z
    end

    def to_s
      "(#{@x},#{@y},#{@z})"
    end

    def inspect
      to_s
    end
  end
end

module Gingham
  class Cell
    attr_accessor :x, :y, :z, :is_occupied, :is_ground

    def initialize(x = 0, y = 0, z = 0)
      @x, @y, @z = x.to_i, y.to_i, z.to_i
      @is_occupied = false
      @is_ground = false
    end

    def ==(other)
      other.is_a?(Gingham::Cell) && @x == other.x && @y == other.y && @z == other.z
    end

    #FIXME
    def occupied?
      @is_occupied
    end

    def passable?
      !@is_occupied
    end

    def sky?
      !@is_ground
    end

    def ground?
      @is_ground
    end

    def to_s
      "(#{x},#{y},#{z})"
    end

    def inspect
      "(#{x},#{y},#{z})"
    end
  end
end

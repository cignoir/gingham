module Gingham
  class Cell
    attr_accessor :x, :y, :z, :is_occupied, :is_ground, :is_move_path, :is_locked

    def initialize(x = 0, y = 0, z = 0)
      @x, @y, @z = x.to_i, y.to_i, z.to_i
      @is_occupied = false
      @is_ground = false
      @is_move_path = false
      @is_locked = false
    end

    def ==(other)
      other.is_a?(Gingham::Cell) && @x == other.x && @y == other.y && @z == other.z
    end

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

    def move_path?
      @is_move_path
    end

    def to_s
      "(#{x},#{y},#{z})"
    end

    def inspect
      to_s
    end

    def set_ground
      @is_ground = true
      self
    end

    def clear_path
      @is_move_path = false unless locked?
    end

    def locked?
      @is_locked
    end

    def lock
      @is_locked = true
    end

    def unlock
      @is_locked = false
    end
  end
end

module Gingham
  class Waypoint
    attr_accessor :cell, :direction, :parent, :cost, :sum_cost, :chains

    class << self
      def detect_direction(from, target_cell)
        raise if from.nil? || from.cell.nil? || from.direction.nil? || target_cell.nil?
        raise unless from.cell.is_a?(Gingham::Cell) && target_cell.is_a?(Gingham::Cell)

        diff_x = target_cell.x - from.cell.x
        diff_y = target_cell.y - from.cell.y

        direction = from.direction
        direction = Gingham::Direction::D6 if diff_x > 0
        direction = Gingham::Direction::D4 if diff_x < 0
        direction = Gingham::Direction::D8 if diff_y > 0
        direction = Gingham::Direction::D2 if diff_y < 0
        direction
      end
    end

    def initialize(cell = Cell.new, direction = Gingham::Direction::D8, parent = nil)
      @cell = cell
      @direction = direction
      @parent = parent

      update
    end

    def calc_cost
      return 0 unless @parent

      is_same_cell = @parent.cell == @cell
      turn_cost = case @parent.direction
        when Gingham::Direction::D8
          case @direction
          when Gingham::Direction::D8 then is_same_cell ? 5 : 0
          when Gingham::Direction::D2 then 10
          else 5
          end
        when Gingham::Direction::D2
          case @direction
          when Gingham::Direction::D2 then is_same_cell ? 5 : 0
          when Gingham::Direction::D8 then 10
          else 5
          end
        when Gingham::Direction::D6
          case @direction
          when Gingham::Direction::D6 then is_same_cell ? 5 : 0
          when Gingham::Direction::D4 then 10
          else 5
          end
        when Gingham::Direction::D4
          case @direction
          when Gingham::Direction::D4 then is_same_cell ? 5 : 0
          when Gingham::Direction::D6 then 10
          else 5
          end
        else 0
        end
      is_same_cell ? turn_cost : 10 + turn_cost
    end

    def pick_parents
      result = []
      result << @parent.chains if @parent
      result << self
      result.flatten.compact
    end

    def update
      if @parent.nil?
        @cost, @sum_cost = 0, 0
        @chains = [self]
      else
        @cost = calc_cost
        @chains = pick_parents
        @sum_cost = @chains.map(&:cost).inject(:+)
      end
      self
    end

    def turning?
      @parent ? @parent.cell == @cell : false
    end

    def moving?
      @parent ? @parent.cell != @cell : false
    end

    def ==(other)
      other.is_a?(Gingham::Waypoint) && @cell == other.cell && @direction == other.direction# && @cost == other.cost && @sum_cost == other.sum_cost
    end

    def to_s
      base = "#{@cell}/#{@direction}" + ":#{@cost}/#{@sum_cost}"
      @parent ? "#{@parent.cell}/#{@parent.direction}->" + base : base
    end

    def inspect
      base = "#{@cell}/#{@direction}" + ":#{@cost}/#{@sum_cost}"
      @parent ? "#{@parent.cell}/#{@parent.direction}->" + base : base
    end
  end
end

module Gingham
  class Actor
    attr_accessor :waypoint, :weight
    attr_accessor :move_steps
    attr_accessor :team_id
    attr_accessor :move_status
    attr_accessor :move_power, :jump_power

    def initialize(waypoint, weight = 100, team_id = 0, move_power = 999, jump_power = 999)
      @waypoint = waypoint
      @weight = weight
      @team_id = team_id
      @move_status = Gingham::MoveStatus::DEFAULT
      @move_power = move_power
      @jump_power = jump_power
      @move_steps = [@waypoint]
    end

    def move_end?
      @move_status == Gingham::MoveStatus::FINISHED || @move_status == Gingham::MoveStatus::STOPPED
    end

    def clear_move_steps(force = false)
      if force
        @move_steps = [@waypoint]
        @waypoint.cell.is_move_path = true
      else
        @move_steps = @move_steps.size.zero? ? [@waypoint] : @move_steps.select(&:locked?)
      end
    end
  end
end

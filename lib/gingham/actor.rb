module Gingham
  class Actor
    attr_accessor :waypoint, :weight
    attr_accessor :move_steps
    attr_accessor :team_id
    attr_accessor :move_status

    def initialize(waypoint, weight = 100, team_id = 0)
      @waypoint = waypoint
      @weight = weight
      @team_id = team_id
      @move_status = Gingham::MoveStatus::DEFAULT
    end

    def move_end?
      @move_status == Gingham::MoveStatus::FINISHED || @move_status == Gingham::MoveStatus::STOPPED
    end
  end
end

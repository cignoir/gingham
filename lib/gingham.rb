require 'active_support/dependencies'

module Gingham
  # Utility
  autoload :VERSION, 'gingham/version'
  autoload :PathFinder, 'gingham/path_finder'
  autoload :MoveSimulator, 'gingham/move_simulator'
  autoload :ActionSimulator, 'gingham/action_simulator'
  autoload :MoveStatus, 'gingham/move_status'

  # World
  autoload :Naterua, 'gingham/naterua' # GameMaster
  autoload :Space, 'gingham/space'
  autoload :Cell, 'gingham/cell'
  autoload :Position, 'gingham/position'
  autoload :Direction, 'gingham/direction'
  autoload :Waypoint, 'gingham/waypoint'

  # Objects
  autoload :Actor, 'gingham/actor'

  # Timeline
  autoload :TimeLine, 'gingham/time_line'
  autoload :MoveFrame, 'gingham/move_frame'
  autoload :ActionFrame, 'gingham/action_frame'
end

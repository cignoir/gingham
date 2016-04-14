require 'gingham'

space = Gingham::Space.new(5, 5, 3)
from = Gingham::Waypoint.new(space.cells[2][1][1], 8)
to = Gingham::Waypoint.new(space.cells[4][4][1], 8)
Gingham::PathFinder.find_skill_path(space, from, to)

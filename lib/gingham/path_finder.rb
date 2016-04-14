module Gingham
  class PathFinder
    class << self
      def find_move_path(space, from, to, cost_limit = 999)
        raise ArgumentError unless space && space.is_a?(Gingham::Space)
        raise ArgumentError unless from && from.is_a?(Gingham::Waypoint) && to && to.is_a?(Gingham::Waypoint)

        open_list = [from]
        return open_list if from.cell == to.cell
        close_list = []
        loop_limit = 0

        while open_list.size > 0 && loop_limit < 1000 do
          current_wp = open_list.first
          close_list << current_wp
          open_list = open_list.drop 1

          adjacent_waypoints = Gingham::PathFinder.find_adjacent_waypoints(space, current_wp)
          adjacent_waypoints.each do |wp|
            if wp.sum_cost < cost_limit
              open_list << wp unless close_list.include? wp
            end
          end
          loop_limit += 1
        end

        shortest_chains = [from]
        end_points = close_list.select{ |closed| closed.cell == to.cell }

        unless end_points.size.zero?
          shortest_cost = 999
          end_points.each do |end_wp|
            if end_wp.sum_cost < shortest_cost
              shortest_cost = end_wp.sum_cost
              shortest_chains = end_wp.chains
            end
          end
        end
        shortest_chains
      end

      def find_skill_path(space, from, to, max_height = 10)
        path = [from]
        last_wp = path.last
        should_move_y = from.direction == Gingham::Direction::D8 || from.direction == Gingham::Direction::D2

        loop_limit = 0
        while last_wp.cell.x != to.cell.x || last_wp.cell.y != to.cell.y
          loop_limit += 1
          break if loop_limit > 30

          if should_move_y && last_wp.cell.y != to.cell.y
            if last_wp.cell.y < to.cell.y
              if last_wp.cell.y + 1 != space.depth
                height = space.height_at(last_wp.cell.x, last_wp.cell.y + 1)
                cell = space.cells[last_wp.cell.x][last_wp.cell.y + 1][height]
                break unless cell.passable?

                if last_wp.direction == 8
                  break if cell.z > max_height
                  wp = Gingham::Waypoint.new(cell, 8, last_wp)
                  path << wp
                  last_wp = wp
                else
                  tmp = Gingham::Waypoint.new(last_wp.cell, 8, last_wp)
                  path << tmp
                  break if cell.z > max_height
                  tmp = Gingham::Waypoint.new(cell, 8, tmp)
                  path << tmp
                  last_wp = tmp
                end
              end
            elsif last_wp.cell.y > to.cell.y
              if last_wp.cell.y - 1 >= 0
                height = space.height_at(last_wp.cell.x, last_wp.cell.y - 1)
                cell = space.cells[last_wp.cell.x][last_wp.cell.y - 1][height]
                break unless cell.passable?

                if last_wp.direction == 2
                  break if cell.z > max_height
                  wp = Gingham::Waypoint.new(cell, 2, last_wp)
                  path << wp
                  last_wp = wp
                else
                  tmp = Gingham::Waypoint.new(last_wp.cell, 2, last_wp)
                  path << tmp
                  break if cell.z > max_height
                  tmp = Gingham::Waypoint.new(cell, 2, tmp)
                  path << tmp
                  last_wp = tmp
                end
              end
            end
            should_move_y = false
            next
          else
            should_move_y = false
          end

          if !should_move_y && last_wp.cell.x != to.cell.x
            if last_wp.cell.x < to.cell.x
              if last_wp.cell.x + 1 != space.width
                height = space.height_at(last_wp.cell.x + 1, last_wp.cell.y)
                cell = space.cells[last_wp.cell.x + 1][last_wp.cell.y][height]
                break unless cell.passable?

                if last_wp.direction == 6
                  break if cell.z > max_height
                  wp = Gingham::Waypoint.new(cell, 6, last_wp)
                  path << wp
                  last_wp = wp
                else
                  tmp = Gingham::Waypoint.new(last_wp.cell, 6, last_wp)
                  path << tmp
                  break if cell.z > max_height
                  tmp = Gingham::Waypoint.new(cell, 6, tmp)
                  path << tmp
                  last_wp = tmp
                end
              end
            elsif last_wp.cell.x > to.cell.x
              if last_wp.cell.x - 1 >= 0
                height = space.height_at(last_wp.cell.x - 1, last_wp.cell.y)
                cell = space.cells[last_wp.cell.x - 1][last_wp.cell.y][height]
                break unless cell.passable?

                if last_wp.direction == 4
                  break if cell.z > max_height
                  wp = Gingham::Waypoint.new(cell, 4, last_wp)
                  path << wp
                  last_wp = wp
                else
                  tmp = Gingham::Waypoint.new(last_wp.cell, 4, last_wp)
                  path << tmp
                  break if cell.z > max_height
                  tmp = Gingham::Waypoint.new(cell, 4, tmp)
                  path << tmp
                  last_wp = tmp
                end
              end
            end
            should_move_y = true
            next
          else
            should_move_y = true
          end
        end

        path.compact
      end
    end

    def self.find_adjacent_waypoints(space, wp)
      raise unless space && space.is_a?(Gingham::Space)
      raise unless wp && wp.is_a?(Gingham::Waypoint)

      adjacent_list = []
      adjacent_cells = Gingham::PathFinder.find_adjacent_cells(space, wp.cell)
      adjacent_cells.each do |cell|
        move_direction = Gingham::Waypoint.detect_direction(wp, cell)
        parent = wp
        if move_direction != wp.direction
          turn_wp = Gingham::Waypoint.new(wp.cell, move_direction, wp)
          parent = turn_wp
        end
        move_to = Gingham::Waypoint.new(cell, move_direction, parent)
        adjacent_list << move_to
      end
      adjacent_list
    end

    def self.find_adjacent_cells(space, cell)
      raise unless space && space.is_a?(Gingham::Space)
      raise unless cell && cell.is_a?(Gingham::Cell)

      adjacent_list = []
      w, d, h = space.width, space.depth, space.height
      x, y, z = cell.x, cell.y, cell.z

      if x + 1 < w
        target_cell = space.cells[x + 1][y][z]
        adjacent_list << target_cell unless target_cell && target_cell.occupied?
      end

      if x - 1 >= 0
        target_cell = space.cells[x - 1][y][z]
        adjacent_list << target_cell unless target_cell && target_cell.occupied?
      end

      if y + 1 < d
        target_cell = space.cells[x][y + 1][z]
        adjacent_list << target_cell unless target_cell && target_cell.occupied?
      end

      if y - 1 >= 0
        target_cell = space.cells[x][y - 1][z]
        adjacent_list << target_cell unless target_cell && target_cell.occupied?
      end

      adjacent_list
    end
  end
end

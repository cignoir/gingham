module Gingham
  class PathFinder
    class << self
      def find_move_path(space, from, to, move_power = 999, jump_power = 999)
        raise ArgumentError unless space && space.is_a?(Gingham::Space)
        raise ArgumentError unless from && from.is_a?(Gingham::Waypoint) && to && to.is_a?(Gingham::Waypoint)

        space.reset_move_path_info(force = false)

        open_list = [from]
        close_list = []
        loop_limit = 0

        while open_list.size > 0 && loop_limit < 1000 do
          current_wp = open_list.first
          close_list << current_wp
          open_list = open_list.drop 1

          adjacent_waypoints = Gingham::PathFinder.find_adjacent_waypoints(space, current_wp, jump_power)
          adjacent_waypoints.each do |wp|
            if wp.sum_cost <= move_power
              unless close_list.include? wp
                wp.cell.is_passable = true
                open_list << wp
              end
            end
          end
          loop_limit += 1
        end

        shortest_chains = from.chains
        end_points = close_list.select { |closed| closed.cell == to.cell }

        unless end_points.size.zero?
          shortest_cost = 999
          end_points.each do |end_wp|
            if end_wp.sum_cost < shortest_cost
              shortest_cost = end_wp.sum_cost
              shortest_chains = end_wp.chains
            end
          end
        end

        shortest_chains.each do |wp|
          wp.cell.is_move_path = true
        end

        shortest_chains
      end

      def find_skill_path(space, from, to, max_height = 999)
        path = [from]
        should_move_y = from.direction == Gingham::Direction::D8 || from.direction == Gingham::Direction::D2

        loop_limit = 0
        while path.last.cell.x != to.cell.x || path.last.cell.y != to.cell.y
          loop_limit += 1
          break if loop_limit > 30

          if should_move_y && path.last.cell.y != to.cell.y
            if path.last.cell.y < to.cell.y
              if path.last.cell.y + 1 != space.depth
                height = space.height_at(path.last.cell.x, path.last.cell.y + 1)
                cell = space.cells[path.last.cell.x][path.last.cell.y + 1][height]
                break if cell.occupied?

                if path.last.direction != 8
                  path << Gingham::Waypoint.new(path.last.cell, 8, path.last)
                end

                break if cell.z > max_height
                path << Gingham::Waypoint.new(cell, 8, path.last)
              end
            elsif path.last.cell.y > to.cell.y
              if path.last.cell.y - 1 >= 0
                height = space.height_at(path.last.cell.x, path.last.cell.y - 1)
                cell = space.cells[path.last.cell.x][path.last.cell.y - 1][height]
                break if cell.occupied?

                if path.last.direction != 2
                  path << Gingham::Waypoint.new(path.last.cell, 2, path.last)
                end

                break if cell.z > max_height
                path << Gingham::Waypoint.new(cell, 2, path.last)
              end
            end
            should_move_y = false
            next
          else
            should_move_y = false
          end

          if !should_move_y && path.last.cell.x != to.cell.x
            if path.last.cell.x < to.cell.x
              if path.last.cell.x + 1 != space.width
                height = space.height_at(path.last.cell.x + 1, path.last.cell.y)
                cell = space.cells[path.last.cell.x + 1][path.last.cell.y][height]
                break if cell.occupied?

                if path.last.direction != 6
                  path << Gingham::Waypoint.new(path.last.cell, 6, path.last)
                end

                break if cell.z > max_height
                path << Gingham::Waypoint.new(cell, 6, path.last)
              end
            elsif path.last.cell.x > to.cell.x
              if path.last.cell.x - 1 >= 0
                height = space.height_at(path.last.cell.x - 1, path.last.cell.y)
                cell = space.cells[path.last.cell.x - 1][path.last.cell.y][height]
                break if cell.occupied?

                if path.last.direction != 4
                  path << Gingham::Waypoint.new(path.last.cell, 4, path.last)
                end

                break if cell.z > max_height
                path << Gingham::Waypoint.new(cell, 4, path.last)
              end
            end
          end

          should_move_y = true
        end

        path.compact
      end
    end

    def self.find_adjacent_waypoints(space, wp, jump_power = 999)
      raise unless space && space.is_a?(Gingham::Space)
      raise unless wp && wp.is_a?(Gingham::Waypoint)

      adjacent_list = []
      adjacent_cells = Gingham::PathFinder.find_adjacent_cells(space, wp.cell, jump_power)
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

    def self.find_adjacent_cells(space, cell, jump_power = 999)
      raise unless space && space.is_a?(Gingham::Space)
      raise unless cell && cell.is_a?(Gingham::Cell)

      adjacent_list = []
      w, d, h = space.width, space.depth, space.height
      x, y, z = cell.x, cell.y, cell.z

      if x + 1 < w
        target_cell = space.ground_at(x + 1, y)
        if target_cell
          if !target_cell.occupied? && (z - target_cell.z).abs <= jump_power
            adjacent_list << target_cell
          end
        end
      end

      if x - 1 >= 0
        target_cell = space.ground_at(x - 1, y)
        if target_cell
          if !target_cell.occupied? && (z - target_cell.z).abs <= jump_power
            adjacent_list << target_cell
          end
        end
      end

      if y + 1 < d
        target_cell = space.ground_at(x, y + 1)
        if target_cell
          if !target_cell.occupied? && (z - target_cell.z).abs <= jump_power
            adjacent_list << target_cell
          end
        end
      end

      if y - 1 >= 0
        target_cell = space.ground_at(x, y - 1)
        if target_cell
          if !target_cell.occupied? && (z - target_cell.z).abs <= jump_power
            adjacent_list << target_cell
          end
        end
      end

      adjacent_list
    end
  end
end

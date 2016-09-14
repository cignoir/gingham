module Gingham
  class Space
    attr_accessor :width, :depth, :height, :cells

    def initialize(width = 0, depth = 0, height = 0)
      @width = width
      @depth = depth
      @height = height
      @cells = Array.new(width){ |x| Array.new(depth){ |y| Array.new(height){ |z| Cell.new(x, y, z) } } }
    end

    # 指定した座標の高さを取得
    def height_at(x, y)
      return nil unless @cells[x][y]

      ground_cells = @cells[x][y].select{ |cell| cell.ground? }
      return 0 if ground_cells.blank?

      z_list = ground_cells.map(&:z)
      return 0 if z_list.blank?

      [0, z_list.max].max
    end

    # 指定した座標の地表のセルを取得
    def ground_at(x, y)
      z = height_at(x, y)
      is_illegal = z.nil? || x < 0 || y < 0 || z < 0 || x >= self.width || y >= self.depth || z >= self.height
      is_illegal ? nil : cells[x][y][z]
    end

    # 中心セルを基準にtargetのセルを回転した位置のセルを取得
    def rotate_right(center, target)
      target ? ground_at(center.x + (target.y - center.y), center.y - (target.x - center.x)) : nil
    end
    def rotate_left(center, target)
      target ? ground_at(center.x - (target.y - center.y), center.y + (target.x - center.x)) : nil
    end
    def rotate_reverse(center, target)
      target ? ground_at(center.x - (target.x - center.x), center.y - (target.y - center.y)) : nil
    end

    def build_range_cell(waypoint, query)
      x = waypoint.cell.x
      y = waypoint.cell.y
      query.to_s.split('').map(&:to_i).each do |n|
        case n
        when 8 then y += 1
        when 2 then y -= 1
        when 6 then x += 1
        when 4 then x -= 1
        end
      end

      target = self.ground_at(x, y)
      result = case waypoint.direction
      when Gingham::Direction::D2 then rotate_reverse(waypoint.cell, target)
      when Gingham::Direction::D6 then rotate_right(waypoint.cell, target)
      when Gingham::Direction::D4 then rotate_left(waypoint.cell, target)
      else target
      end

      (result.nil? || result.occupied?) ? nil : result
    end

    def build_all_range_cells(waypoint, query_list)
      result = []
      query_list.each do |query|
        range_cell = build_range_cell(waypoint, query)
        result << range_cell unless range_cell.nil?
      end
      result.uniq
    end
  end
end

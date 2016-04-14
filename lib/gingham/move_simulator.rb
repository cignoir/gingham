module Gingham
  class MoveSimulator
    class << self
      def next_step(current_step_index, actors)
        actors.each do |actor|
          actor.move_status = Gingham::MoveStatus::FINISHED unless actor.move_steps[current_step_index + 1]
        end

        grouped = actors.reject{ |actor| actor.move_end? }.group_by{ |actor| actor.move_steps[current_step_index + 1].cell }
        grouped.each do |goal, group|
          if actors.map{ |a| a.waypoint.cell }.include? goal
            # ゴール地点に誰かいる場合
            # 方向転換の場合、ゴール地点に自分自身がいることになることに注意
            winner = actors.select{ |a| a.waypoint.cell == goal }.first
            losers = group.reject{ |actor| actor.object_id == winner.object_id }
            all_in_goal = [winner, losers].flatten.compact
          else
            # ゴール地点に誰もいない場合
            max_weight = group.map(&:weight).max
            winner = group.select{ |actor| actor.weight == max_weight }.sample
            winner.waypoint = winner.move_steps[current_step_index + 1]
            winner.move_status = Gingham::MoveStatus::DEFAULT
            losers = group.reject{ |actor| actor.object_id == winner.object_id }
            all_in_goal = [winner, losers].flatten.compact
          end

          if all_in_goal.map(&:team_id).uniq.size == 1
            # 全員同じチームの場合
            losers.each do |loser|
              loser.move_status = Gingham::MoveStatus::STAY
              # 足踏みステップを挿入
              loser.move_steps = loser.move_steps.insert(current_step_index, loser.move_steps[current_step_index])
            end
          else
            # 敵チームを含んでいる場合
            winner.move_steps = winner.move_steps[0..(current_step_index + 1)]
            winner.move_status = Gingham::MoveStatus::STOPPED
            losers.each do |loser|
              loser.move_status = Gingham::MoveStatus::STOPPED
              loser.move_steps = loser.move_steps[0..current_step_index] # 以降のmove_stepsを削除
            end
          end
        end
        actors
      end

      def record(actors)
        all_moved = actors.select(&:move_end?).size == actors.size
        all_stayed = actors.reject(&:move_end?).map(&:move_status).uniq.first == Gingham::MoveStatus::STAY

        index = 0
        records = [MoveFrame.new(index, actors)]
        until all_moved || all_stayed
          actors = self.next_step(index, actors)
          index += 1
          records << MoveFrame.new(index, actors)

          all_moved = actors.select(&:move_end?).size == actors.size
          all_stayed = actors.reject(&:move_end?).map(&:move_status).uniq.first == Gingham::MoveStatus::STAY
        end

        records
      end
    end
  end
end

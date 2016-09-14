require 'spec_helper'

describe Gingham::MoveSimulator do
  include Gingham::Direction

  it 'is defined' do
    expect { Gingham::MoveSimulator }.not_to raise_error
  end

  describe '#next_step' do
    let(:naterua) { Gingham::Naterua.new }
    let(:space) { Gingham::Space.new(5, 5, 3) }
    let(:actors) { [p1, p2, p3, p4] }
    let(:same_goal) { space.cells[2][2][1] }

    let(:p1) { Gingham::Actor.new(p1_wp_from, p1_weight) }
    let(:p1_wp_from) { Gingham::Waypoint.new(p1_cell, p1_direction) }
    let(:p1_cell) { space.cells[2][1][1] }
    let(:p1_direction) { Gingham::Direction::D8 }
    let(:p1_weight) { 100 }
    let(:p1_team_id) { 0 }
    let(:p1_move_steps) { Gingham::PathFinder.find_move_path(space, p1_wp_from, p1_wp_to) }

    let(:p2) { Gingham::Actor.new(p2_wp_from, p2_weight) }
    let(:p2_wp_from) { Gingham::Waypoint.new(p2_cell, p2_direction) }
    let(:p2_cell) { space.cells[3][2][1] }
    let(:p2_direction) { Gingham::Direction::D8 }
    let(:p2_weight) { 100 }
    let(:p2_team_id) { 0 }
    let(:p2_move_steps) { Gingham::PathFinder.find_move_path(space, p2_wp_from, p2_wp_to) }

    let(:p3) { Gingham::Actor.new(p3_wp_from, p3_weight) }
    let(:p3_wp_from) { Gingham::Waypoint.new(p3_cell, p3_direction) }
    let(:p3_cell) { space.cells[2][3][1] }
    let(:p3_direction) { Gingham::Direction::D8 }
    let(:p3_weight) { 100 }
    let(:p3_team_id) { 0 }
    let(:p3_move_steps) { Gingham::PathFinder.find_move_path(space, p3_wp_from, p3_wp_to) }

    let(:p4) { Gingham::Actor.new(p4_wp_from, p4_weight) }
    let(:p4_wp_from) { Gingham::Waypoint.new(p4_cell, p4_direction) }
    let(:p4_cell) { space.cells[1][2][1] }
    let(:p4_direction) { Gingham::Direction::D8 }
    let(:p4_weight) { 100 }
    let(:p4_team_id) { 0 }
    let(:p4_move_steps) { Gingham::PathFinder.find_move_path(space, p4_wp_from, p4_wp_to) }

    let(:p5) { Gingham::Actor.new(p5_wp_from, 100) }
    let(:p5_wp_from) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D8) }
    let(:p5_move_steps) { [p5_wp_from] }

    before do
      space.cells.flatten.select{ |cell| cell.z == 1 }.each(&:set_ground)

      naterua.step_index = 0

      p1.move_steps = p1_move_steps
      p1.weight = p1_weight
      p1.team_id = p1_team_id

      p2.move_steps = p2_move_steps
      p2.weight = p2_weight
      p2.team_id = p2_team_id

      p3.move_steps = p3_move_steps
      p3.weight = p3_weight
      p3.team_id = p3_team_id

      p4.move_steps = p4_move_steps
      p4.weight = p4_weight
      p4.team_id = p4_team_id

      p5.move_steps = p5_move_steps
    end

    context 'when anyone does not interfere' do
      let(:p1_direction) { Gingham::Direction::D8 }
      let(:p1_wp_to) { Gingham::Waypoint.new(space.cells[2][2][1], Gingham::Direction::D8) }
      let(:p2_direction) { Gingham::Direction::D8 }
      let(:p2_wp_to) { Gingham::Waypoint.new(space.cells[3][3][1], Gingham::Direction::D8) }
      let(:p3_direction) { Gingham::Direction::D8 }
      let(:p3_wp_to) { Gingham::Waypoint.new(space.cells[2][4][1], Gingham::Direction::D8) }
      let(:p4_direction) { Gingham::Direction::D8 }
      let(:p4_wp_to) { Gingham::Waypoint.new(space.cells[1][3][1], Gingham::Direction::D8) }

      it 'All reach the goal' do
        Gingham::MoveSimulator.next_step(naterua.step_index, actors)

        expect(p1.waypoint).to eq p1_wp_to
        expect(p1.move_status).to eq Gingham::MoveStatus::DEFAULT
        expect(p2.waypoint).to eq p2_wp_to
        expect(p2.move_status).to eq Gingham::MoveStatus::DEFAULT
        expect(p3.waypoint).to eq p3_wp_to
        expect(p3.move_status).to eq Gingham::MoveStatus::DEFAULT
        expect(p4.waypoint).to eq p4_wp_to
        expect(p4.move_status).to eq Gingham::MoveStatus::DEFAULT
      end
    end

    context 'The goal is already occupied' do
      let(:actors) { [p1, p2, p3, p4, p5] }

      context 'when more than one person tries to enter the same cell' do
        let(:p1_direction) { Gingham::Direction::D8 }
        let(:p1_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D8) }
        let(:p2_direction) { Gingham::Direction::D4 }
        let(:p2_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D4) }
        let(:p3_direction) { Gingham::Direction::D2 }
        let(:p3_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D2) }
        let(:p4_direction) { Gingham::Direction::D6 }
        let(:p4_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D6) }

        context 'when not including enemies' do
          context 'and p1 is the heaviest' do
            let(:p1_weight) { 101 }

            it 'No one reaches the goal' do
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(p1.waypoint).to eq p1_wp_from
              expect(p1.move_status).to eq Gingham::MoveStatus::STAY
              expect(p1.move_steps.size).to eq 3
              expect(p2.waypoint).to eq p2_wp_from
              expect(p2.move_status).to eq Gingham::MoveStatus::STAY
              expect(p2.move_steps.size).to eq 3
              expect(p3.waypoint).to eq p3_wp_from
              expect(p3.move_status).to eq Gingham::MoveStatus::STAY
              expect(p3.move_steps.size).to eq 3
              expect(p4.waypoint).to eq p4_wp_from
              expect(p4.move_status).to eq Gingham::MoveStatus::STAY
              expect(p4.move_steps.size).to eq 3
              expect(p5.waypoint).to eq p5_wp_from
            end
          end
        end

        context 'when including enemies' do
          let(:p1_team_id) { 0 }
          let(:p2_team_id) { 1 }

          context 'and p1 is the heaviest' do
            let(:p1_weight) { 101 }

            it 'No one reach the goal' do
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(p1.waypoint).to eq p1_wp_from
              expect(p1.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p1.move_steps.size).to eq 1
              expect(p2.waypoint).to eq p2_wp_from
              expect(p2.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p2.move_steps.size).to eq 1
              expect(p3.waypoint).to eq p3_wp_from
              expect(p3.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p3.move_steps.size).to eq 1
              expect(p4.waypoint).to eq p4_wp_from
              expect(p4.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p4.move_steps.size).to eq 1
              expect(p5.waypoint).to eq p5_wp_from
              expect(p5.move_status).to eq Gingham::MoveStatus::STOPPED
            end
          end
        end
      end
    end

    context 'The goal is NOT already occupied' do
      context 'when more than one person tries to enter the same cell' do
        let(:p1_direction) { Gingham::Direction::D8 }
        let(:p1_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D8) }
        let(:p2_direction) { Gingham::Direction::D4 }
        let(:p2_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D4) }
        let(:p3_direction) { Gingham::Direction::D2 }
        let(:p3_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D2) }
        let(:p4_direction) { Gingham::Direction::D6 }
        let(:p4_wp_to) { Gingham::Waypoint.new(same_goal, Gingham::Direction::D6) }

        context 'when not including enemies' do
          context 'and p1 is the heaviest' do
            let(:p1_weight) { 101 }

            it 'Only p1 reaches the goal' do
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(p1.waypoint).to eq p1_wp_to
              expect(p1.move_status).to eq Gingham::MoveStatus::DEFAULT
              expect(p1.move_steps.size).to eq 2
              expect(p2.waypoint).to eq p2_wp_from
              expect(p2.move_status).to eq Gingham::MoveStatus::STAY
              expect(p2.move_steps.size).to eq 3
              expect(p3.waypoint).to eq p3_wp_from
              expect(p3.move_status).to eq Gingham::MoveStatus::STAY
              expect(p3.move_steps.size).to eq 3
              expect(p4.waypoint).to eq p4_wp_from
              expect(p4.move_status).to eq Gingham::MoveStatus::STAY
              expect(p4.move_steps.size).to eq 3
            end
          end

          context 'and p2 and p3 are the heaviest' do
            let(:p2_weight) { 101 }
            let(:p3_weight) { 101 }

            it 'One of the heaviest reaches the goal' do
              allow_any_instance_of(Array).to receive(:sample).and_return(p3) # not working?
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(actors.select { |a| a.waypoint.cell == same_goal }.size).to eq 1
              expect(actors.reject { |a| a.waypoint.cell == same_goal }.size).to eq 3
              expect(actors.select { |a| a.move_status == Gingham::MoveStatus::DEFAULT }.size).to eq 1
              expect(actors.select { |a| a.move_status == Gingham::MoveStatus::STAY }.size).to eq 3
            end
          end
        end

        context 'when including enemies' do
          let(:p1_team_id) { 0 }
          let(:p2_team_id) { 1 }

          context 'and p1 is the heaviest' do
            let(:p1_weight) { 101 }

            it 'Only p1 reaches the goal' do
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(p1.waypoint).to eq p1_wp_to
              expect(p1.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p1.move_steps.size).to eq 2
              expect(p2.waypoint).to eq p2_wp_from
              expect(p2.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p2.move_steps.size).to eq 1
              expect(p3.waypoint).to eq p3_wp_from
              expect(p3.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p3.move_steps.size).to eq 1
              expect(p4.waypoint).to eq p4_wp_from
              expect(p4.move_status).to eq Gingham::MoveStatus::STOPPED
              expect(p4.move_steps.size).to eq 1
            end
          end

          context 'and p2 and p3 are the heaviest' do
            let(:p2_weight) { 101 }
            let(:p3_weight) { 101 }

            it 'One of the heaviest reaches the goal' do
              allow_any_instance_of(Array).to receive(:sample).and_return(p3) # not working?
              Gingham::MoveSimulator.next_step(naterua.step_index, actors)

              expect(p3.waypoint.cell).to eq same_goal
              expect([p1, p2, p4].map { |p| p.waypoint.cell }).not_to include same_goal
              expect(actors.select { |a| a.move_status == Gingham::MoveStatus::STOPPED }.size).to eq 4
            end
          end
        end
      end
    end
  end

  describe '#simulate' do
    let(:space) { Gingham::Space.new(5, 5, 3) }
    let(:actors) { [p1, p2] }

    let(:p1) { Gingham::Actor.new(p1_wp_from, p1_weight) }
    let(:p1_wp_from) { Gingham::Waypoint.new(p1_cell, p1_direction) }
    let(:p1_wp_to) { Gingham::Waypoint.new(space.cells[2][4][1], p1_direction) }
    let(:p1_cell) { space.cells[2][1][1] }
    let(:p1_direction) { Gingham::Direction::D8 }
    let(:p1_weight) { 100 }
    let(:p1_team_id) { 0 }
    let(:p1_move_steps) { Gingham::PathFinder.find_move_path(space, p1_wp_from, p1_wp_to) }

    let(:p2) { Gingham::Actor.new(p2_wp_from, p2_weight) }
    let(:p2_wp_from) { Gingham::Waypoint.new(p2_cell, p2_direction) }
    let(:p2_wp_to) { Gingham::Waypoint.new(space.cells[1][1][1], Gingham::Direction::D4) }
    let(:p2_cell) { space.cells[3][2][1] }
    let(:p2_direction) { Gingham::Direction::D8 }
    let(:p2_weight) { 100 }
    let(:p2_team_id) { 0 }
    let(:p2_move_steps) { Gingham::PathFinder.find_move_path(space, p2_wp_from, p2_wp_to) }

    before do
      space.cells.flatten.select{ |cell| cell.z == 1 }.each(&:set_ground)

      p1.move_steps = p1_move_steps
      p1.weight = p1_weight
      p1.team_id = p1_team_id

      p2.move_steps = p2_move_steps
      p2.weight = p2_weight
      p2.team_id = p2_team_id

      Gingham::MoveSimulator.record(actors)
    end

    context 'when there are no collision' do
      it 'simulate all steps' do
        expect(p1.waypoint.cell).to eq p1_wp_to.cell
        expect(p2.waypoint.cell).to eq p2_wp_to.cell
      end
    end

    context 'when there are collision' do
      let(:p1_weight) { 101 }
      let(:p2_direction) { Gingham::Direction::D4 }

      context 'same team' do
        it 'can be simulated all steps' do
          expect(p1.waypoint.cell).to eq p1_wp_to.cell
          expect(p2.waypoint.cell).to eq p2_wp_to.cell
        end

        context 'glaring at each other' do
          let(:p2_cell) { space.cells[2][3][1] }
          let(:p2_direction) { Gingham::Direction::D2 }
          let(:p2_wp_to) { Gingham::Waypoint.new(space.cells[2][0][1], Gingham::Direction::D4) }

          it 'can be simulated all steps' do
            expect(p1.waypoint.cell).to eq space.cells[2][2][1] #heavier
            expect(p1.waypoint.direction).to eq Gingham::Direction::D8
            expect(p1.move_status).to eq Gingham::MoveStatus::STAY
            expect(p2.waypoint).to eq p2_wp_from
            expect(p2.move_status).to eq Gingham::MoveStatus::STAY
          end
        end
      end

      context 'not same team' do
        let(:p2_team_id) { 1 }

        context 'p1 is heavier' do
          let(:p1_weight) { 101 }
          let(:p2_weight) { 100 }

          it 'can be simulated all steps' do
            expect(p1.waypoint.cell).to eq space.cells[2][2][1] # heavier
            expect(p2.waypoint).to eq p2_wp_from
          end
        end

        context 'p2 is heavier' do
          let(:p1_weight) { 100 }
          let(:p2_weight) { 101 }

          it 'can be simulated all steps' do
            expect(p1.waypoint).to eq p1_wp_from
            expect(p2.waypoint.cell).to eq space.cells[2][2][1] # heavier
            expect(p2.waypoint.direction).to eq Gingham::Direction::D4
          end
        end
      end
    end
  end
end

require 'spec_helper'

describe Gingham::PathFinder do
  it 'is defined' do
    expect { Gingham::PathFinder }.not_to raise_error
  end

  describe 'find_adjacent_waypoints' do
    subject { Gingham::PathFinder.find_adjacent_waypoints(space, wp) }

    describe 'error' do
      let(:space) { nil }
      let(:wp) { nil }
      it { expect { subject }.to raise_error }
    end

    context 'when there are enough adjacent cells' do
      let(:space) { Gingham::Space.new(3, 3, 3) }
      let(:wp) { Gingham::Waypoint.new(space.cells[1][1][1], Gingham::Direction::D8) }

      before do
        space.cells.flatten.select{ |cell| cell.z == 1 }.each(&:set_ground)
      end

      it { is_expected.to include Gingham::Waypoint.new(space.cells[1][2][1], Gingham::Direction::D8, wp) }
      it { is_expected.to include Gingham::Waypoint.new(space.cells[2][1][1], Gingham::Direction::D6, wp) }
      it { is_expected.to include Gingham::Waypoint.new(space.cells[1][0][1], Gingham::Direction::D2, wp) }
      it { is_expected.to include Gingham::Waypoint.new(space.cells[0][1][1], Gingham::Direction::D4, wp) }
    end

    context 'when there are not enough adjacent cells' do
      let(:space) { Gingham::Space.new(1, 1, 1) }
      let(:wp) { Gingham::Waypoint.new(space.cells[0][0][0], Gingham::Direction::D8) }
      it { expect(subject.size).to be_zero }
    end
  end

  describe 'find_adjacent_cells' do
    subject { Gingham::PathFinder.find_adjacent_cells(space, cell) }

    describe 'error' do
      let(:space) { nil }
      let(:cell) { nil }
      it { expect { subject }.to raise_error }
    end

    context 'when there are enough adjacent cells' do
      let(:space) { Gingham::Space.new(3, 3, 3) }
      let(:cell) { space.cells[1][1][1] }

      before do
        space.cells.flatten.select{ |cell| cell.z == 1 }.each(&:set_ground)
      end

      it { is_expected.to include space.cells[1][2][1] }
      it { is_expected.to include space.cells[2][1][1] }
      it { is_expected.to include space.cells[1][0][1] }
      it { is_expected.to include space.cells[0][1][1] }
    end

    context 'when there are not enough adjacent cells' do
      let(:space) { Gingham::Space.new(1, 1, 1) }
      let(:cell) { Gingham::Cell.new(0, 0, 0) }

      it { expect(subject.size).to be_zero }
    end

    # context 'when jump_power is given' do
    #   let(:space) { Gingham::Space.new(3, 3, 3) }
    #   let(:cell) { space.cells[1][1][1] }
    #   let(:jump_power) { 0 }
    #   subject { Gingham::PathFinder.find_adjacent_cells(space, cell, jump_power) }
    # end
  end

  describe 'find_move_path' do
    subject { Gingham::PathFinder.find_move_path(space, wp_from, wp_to) }

    describe 'error' do
      let(:space) { nil }
      it { expect { subject }.to raise_error }
    end

    describe 'path finding' do
      let(:height) { 3 }
      let(:z) { 0 }

      let(:space) { Gingham::Space.new(5, 5, height) }
      let(:cell_from) { space.cells[2][1][z] }
      let(:direction_from) { Gingham::Direction::D8 }
      let(:wp_from) { Gingham::Waypoint.new(cell_from, direction_from) }
      let(:wp_to) { Gingham::Waypoint.new(cell_to, direction_to) }
      let(:direction_to) { Gingham::Direction::D8 }

      context 'when (2, 1)/8 -> (2, 2)/8' do
        let(:cell_to) { space.cells[2][2][z] }
        it { is_expected.to include wp_from }
        it { is_expected.to include wp_to }
        it { expect(subject.size).to be 2 }
        it { expect(subject.last.parent).to eq wp_from }
        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 10 }
      end

      context 'when (2, 1)/8 -> (2, 3)/8' do
        let(:cell_to) { space.cells[2][3][z] }
        let(:wp1) { Gingham::Waypoint.new(space.cells[2][2][z], Gingham::Direction::D8) }
        it { is_expected.to include wp_from }
        it { is_expected.to include wp1 }
        it { is_expected.to include wp_to }
        it { expect(subject.size).to be 3 }
        it { expect(subject.last.parent).to eq wp1 }
        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 20 }
      end

      context 'when (2, 1)/8 -> (2, 3)/6' do
        let(:cell_to) { space.cells[2][3][z] }
        let(:wp1) { Gingham::Waypoint.new(space.cells[2][2][z], Gingham::Direction::D8) }
        it { is_expected.to include wp_from }
        it { is_expected.to include wp1 }
        # Path::find は最短経路を求めるだけなので終点の向きを無視する
        it { is_expected.to include Gingham::Waypoint.new(Gingham::Cell.new(2, 3, z), Gingham::Direction::D8) }
        it { expect(subject.size).to be 3 }
        it { expect(subject.last.parent).to eq wp1 }
        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 20 }
      end

      context 'when (2, 1)/8 -> (3, 1)/6' do
        let(:cell_to) { space.cells[3][1][z] }
        it { is_expected.to include wp_from }
        it { is_expected.to include Gingham::Waypoint.new(space.cells[3][1][z], Gingham::Direction::D6) }
        it { expect(subject.size).to be 3 }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq cell_from }
        it { expect(subject[1].direction).to eq 6 }
        it { expect(subject[1].cost).to eq 5 }
        it { expect(subject[1].sum_cost).to eq 5 }

        it { expect(subject.last.parent).to eq subject[1] }
        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 15 }
      end

      context 'when (2, 1)/8 -> (4, 1)/6' do
        let(:cell_to) { Gingham::Cell.new(4, 1, z) }
        let(:wp1) { Gingham::Waypoint.new(Gingham::Cell.new(3, 1, z), Gingham::Direction::D6) }
        it { is_expected.to include wp_from }
        it { expect(subject.last.parent).to eq wp1 }
        it { is_expected.to include Gingham::Waypoint.new(Gingham::Cell.new(4, 1, z), Gingham::Direction::D6) }
        it { expect(subject.size).to be 4 }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq cell_from }
        it { expect(subject[1].direction).to eq 6 }
        it { expect(subject[1].cost).to eq 5 }
        it { expect(subject[1].sum_cost).to eq 5 }

        it { expect(subject[2].parent).to eq subject[1] }
        it { expect(subject[2].cell).to eq wp1.cell }
        it { expect(subject[2].direction).to eq 6 }
        it { expect(subject[2].cost).to eq 10 }
        it { expect(subject[2].sum_cost).to eq 15 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 25 }
      end

      context 'when (2, 1)/8 -> (3, 2)/6' do
        let(:cell_to) { Gingham::Cell.new(3, 2, z) }

        it { is_expected.to include wp_from }
        it { is_expected.to include Gingham::Waypoint.new(cell_to, 6) }
        it { expect(subject.size).to eq 4 }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq Gingham::Cell.new(2, 2, z) }
        it { expect(subject[1].direction).to eq 8 }
        it { expect(subject[1].cost).to eq 10 }
        it { expect(subject[1].sum_cost).to eq 10 }

        it { expect(subject[2].parent).to eq subject[1] }
        it { expect(subject[2].cell).to eq Gingham::Cell.new(2, 2, z) }
        it { expect(subject[2].direction).to eq 6 }
        it { expect(subject[2].cost).to eq 5 }
        it { expect(subject[2].sum_cost).to eq 15 }

        it { expect(subject[3].parent).to eq subject[2] }
        it { expect(subject[3].cell).to eq Gingham::Cell.new(3, 2, z) }
        it { expect(subject[3].direction).to eq 6 }
        it { expect(subject[3].cost).to eq 10 }
        it { expect(subject[3].sum_cost).to eq 25 }
      end

      context 'when (2, 1)/8 -> (2, 0)/2' do
        let(:cell_to) { Gingham::Cell.new(2, 0, z) }

        it { expect(subject.size).to eq 3 }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq Gingham::Cell.new(2, 1, z) }
        it { expect(subject[1].direction).to eq 2 }
        it { expect(subject[1].cost).to eq 10 }
        it { expect(subject[1].sum_cost).to eq 10 }

        it { expect(subject[2].parent).to eq subject[1] }
        it { expect(subject[2].cell).to eq Gingham::Cell.new(2, 0, z) }
        it { expect(subject[2].direction).to eq 2 }
        it { expect(subject[2].cost).to eq 10 }
        it { expect(subject[2].sum_cost).to eq 20 }
      end

      context 'when (2, 1)/8 -> (1, 0)/2' do
        let(:cell_to) { Gingham::Cell.new(1, 0, z) }

        it { expect(subject.size).to eq 5 }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq Gingham::Cell.new(2, 1, z) }
        it { expect(subject[1].direction).to eq 4 }
        it { expect(subject[1].cost).to eq 5 }
        it { expect(subject[1].sum_cost).to eq 5 }

        it { expect(subject[2].parent).to eq subject[1] }
        it { expect(subject[2].cell).to eq Gingham::Cell.new(1, 1, z) }
        it { expect(subject[2].direction).to eq 4 }
        it { expect(subject[2].cost).to eq 10 }
        it { expect(subject[2].sum_cost).to eq 15 }

        it { expect(subject[3].parent).to eq subject[2] }
        it { expect(subject[3].cell).to eq Gingham::Cell.new(1, 1, z) }
        it { expect(subject[3].direction).to eq 2 }
        it { expect(subject[3].cost).to eq 5 }
        it { expect(subject[3].sum_cost).to eq 20 }

        it { expect(subject[4].parent).to eq subject[3] }
        it { expect(subject[4].cell).to eq Gingham::Cell.new(1, 0, z) }
        it { expect(subject[4].direction).to eq 2 }
        it { expect(subject[4].cost).to eq 10 }
        it { expect(subject[4].sum_cost).to eq 30 }
      end

      context 'when (2, 1)/8 -> (0, 0)/2' do
        let(:cell_to) { Gingham::Cell.new(0, 0, z) }

        it { expect(subject[1].parent).to eq wp_from }
        it { expect(subject[1].cell).to eq Gingham::Cell.new(2, 1, z) }
        it { expect(subject[1].direction).to eq 4 }
        it { expect(subject[1].cost).to eq 5 }
        it { expect(subject[1].sum_cost).to eq 5 }

        it { expect(subject[2].parent).to eq subject[1] }
        it { expect(subject[2].cell).to eq Gingham::Cell.new(1, 1, z) }
        it { expect(subject[2].direction).to eq 4 }
        it { expect(subject[2].cost).to eq 10 }
        it { expect(subject[2].sum_cost).to eq 15 }

        it { expect(subject[3].parent).to eq subject[2] }
        it { expect(subject[3].cell).to eq Gingham::Cell.new(0, 1, z) }
        it { expect(subject[3].direction).to eq 4 }
        it { expect(subject[3].cost).to eq 10 }
        it { expect(subject[3].sum_cost).to eq 25 }

        it { expect(subject[4].parent).to eq subject[3] }
        it { expect(subject[4].cell).to eq Gingham::Cell.new(0, 1, z) }
        it { expect(subject[4].direction).to eq 2 }
        it { expect(subject[4].cost).to eq 5 }
        it { expect(subject[4].sum_cost).to eq 30 }

        it { expect(subject[5].parent).to eq subject[4] }
        it { expect(subject[5].cell).to eq Gingham::Cell.new(0, 0, z) }
        it { expect(subject[5].direction).to eq 2 }
        it { expect(subject[5].cost).to eq 10 }
        it { expect(subject[5].sum_cost).to eq 40 }
      end
    end
  end

  describe 'find_skill_path' do
    subject { Gingham::PathFinder.find_skill_path(space, wp_from, wp_to) }

    describe 'error' do
      let(:space) { nil }
      it { expect { subject }.to raise_error }
    end

    describe 'path finding' do
      let(:height) { 3 }
      let(:z) { 0 }

      let(:space) { Gingham::Space.new(5, 5, height) }
      let(:cell_from) { Gingham::Cell.new(2, 1, z) }
      let(:direction_from) { Gingham::Direction::D8 }
      let(:wp_from) { Gingham::Waypoint.new(cell_from, direction_from) }
      let(:wp_to) { Gingham::Waypoint.new(cell_to, direction_to) }
      let(:direction_to) { Gingham::Direction::D8 }

      context 'when (2, 1)/8 -> (2, 2)' do
        let(:cell_to) { Gingham::Cell.new(2, 2, z) }
        it { is_expected.to include wp_from }
        it { is_expected.to include wp_to }
        it { expect(subject.size).to be 2 }
        it { expect(subject.last.parent).to eq wp_from }
        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 10 }
      end

      context 'when (2, 1)/8 -> (3, 2)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y2d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, z), 8) }
        let(:x2y2d6) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, z), 6) }
        let(:x3y2d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 2, z), 6) }
        let(:cell_to) { Gingham::Cell.new(3, 2, z) }

        it { expect(subject.size).to be 4 }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[1]).to eq x2y2d8 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x2y2d6 }
        it { expect(subject[2].parent).to eq x2y2d8 }
        it { expect(subject.last).to eq x3y2d6 }
        it { expect(subject.last.parent).to eq x2y2d6 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 25 }
      end

      context 'when (2, 1)/8 -> (3, 1)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y1d6) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 6) }
        let(:x3y1d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 1, z), 6) }
        let(:cell_to) { Gingham::Cell.new(3, 1, z) }

        it { expect(subject.size).to be 3 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[1]).to eq x2y1d6 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject.last).to eq x3y1d6 }
        it { expect(subject.last.parent).to eq x2y1d6 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 15 }
      end

      context 'when (2, 1)/8 -> (0, 1)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y1d4) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 4) }
        let(:x1y1d4) { Gingham::Waypoint.new(Gingham::Cell.new(1, 1, z), 4) }
        let(:x0y1d4) { Gingham::Waypoint.new(Gingham::Cell.new(0, 1, z), 4) }
        let(:cell_to) { Gingham::Cell.new(0, 1, z) }

        it { expect(subject.size).to be 4 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[1]).to eq x2y1d4 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x1y1d4 }
        it { expect(subject[2].parent).to eq x2y1d4 }
        it { expect(subject.last).to eq x0y1d4 }
        it { expect(subject.last.parent).to eq x1y1d4 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 25 }
      end

      context 'when (2, 1)/8 -> (4, 4)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y2d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, z), 8) }
        let(:x2y2d6) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, z), 6) }
        let(:x3y2d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 2, z), 6) }
        let(:x3y2d8) { Gingham::Waypoint.new(Gingham::Cell.new(3, 2, z), 8) }
        let(:x3y3d8) { Gingham::Waypoint.new(Gingham::Cell.new(3, 3, z), 8) }
        let(:x3y3d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 3, z), 6) }
        let(:x4y3d6) { Gingham::Waypoint.new(Gingham::Cell.new(4, 3, z), 6) }
        let(:x4y3d8) { Gingham::Waypoint.new(Gingham::Cell.new(4, 3, z), 8) }
        let(:x4y4d8) { Gingham::Waypoint.new(Gingham::Cell.new(4, 4, z), 8) }

        let(:cell_to) { Gingham::Cell.new(4, 4, z) }
        it { expect(subject.size).to eq 10 }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[1]).to eq x2y2d8 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x2y2d6 }
        it { expect(subject[2].parent).to eq x2y2d8 }
        it { expect(subject[3]).to eq x3y2d6 }
        it { expect(subject[3].parent).to eq x2y2d6 }
        it { expect(subject[4]).to eq x3y2d8 }
        it { expect(subject[4].parent).to eq x3y2d6 }
        it { expect(subject[5]).to eq x3y3d8 }
        it { expect(subject[5].parent).to eq x3y2d8 }
        it { expect(subject[6]).to eq x3y3d6 }
        it { expect(subject[6].parent).to eq x3y3d8 }
        it { expect(subject[7]).to eq x4y3d6 }
        it { expect(subject[7].parent).to eq x3y3d6 }
        it { expect(subject[8]).to eq x4y3d8 }
        it { expect(subject[8].parent).to eq x4y3d6 }
        it { expect(subject[9]).to eq x4y4d8 }
        it { expect(subject[9].parent).to eq x4y3d8 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 70 }
      end

      context 'when (2, 1)/8 -> (1, 0)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y1d2) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 2) }
        let(:x2y0d2) { Gingham::Waypoint.new(Gingham::Cell.new(2, 0, z), 2) }
        let(:x2y0d4) { Gingham::Waypoint.new(Gingham::Cell.new(2, 0, z), 4) }
        let(:x1y0d4) { Gingham::Waypoint.new(Gingham::Cell.new(1, 0, z), 4) }
        let(:cell_to) { Gingham::Cell.new(1, 0, z) }

        it { expect(subject.size).to be 5 }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[1]).to eq x2y1d2 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x2y0d2 }
        it { expect(subject[2].parent).to eq x2y1d2 }
        it { expect(subject[3]).to eq x2y0d4 }
        it { expect(subject[3].parent).to eq x2y0d2 }
        it { expect(subject[4]).to eq x1y0d4 }
        it { expect(subject[4].parent).to eq x2y0d4 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 35 }
      end

      context 'when (2, 1)/8 -> (3, 0)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 8) }
        let(:x2y1d2) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 2) }
        let(:x2y0d2) { Gingham::Waypoint.new(Gingham::Cell.new(2, 0, z), 2) }
        let(:x2y0d6) { Gingham::Waypoint.new(Gingham::Cell.new(2, 0, z), 6) }
        let(:x3y0d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 0, z), 6) }
        let(:cell_to) { Gingham::Cell.new(3, 0, z) }

        it { expect(subject.size).to be 5 }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[1]).to eq x2y1d2 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x2y0d2 }
        it { expect(subject[2].parent).to eq x2y1d2 }
        it { expect(subject[3]).to eq x2y0d6 }
        it { expect(subject[3].parent).to eq x2y0d2 }
        it { expect(subject[4]).to eq x3y0d6 }
        it { expect(subject[4].parent).to eq x2y0d6 }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 35 }
      end

      context 'when (2, 1)/6 -> (3, 1)' do
        let(:wp_from) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 6) }
        let(:x3y1d6) { Gingham::Waypoint.new(Gingham::Cell.new(3, 1, z), 6) }
        let(:cell_to) { Gingham::Cell.new(3, 1, z) }

        it { expect(subject.size).to be 2 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[0]).to eq wp_from }
        it { expect(subject.last).to eq x3y1d6 }
        it { expect(subject.last.parent).to eq wp_from }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 10 }
      end

      context 'when (2, 1)/2 -> (2, 0)' do
        let(:wp_from) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, z), 2) }
        let(:x2y0d2) { Gingham::Waypoint.new(Gingham::Cell.new(2, 0, z), 2) }
        let(:cell_to) { Gingham::Cell.new(2, 0, z) }

        it { expect(subject.size).to be 2 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[0]).to eq wp_from }
        it { expect(subject.last).to eq x2y0d2 }
        it { expect(subject.last.parent).to eq wp_from }

        it { expect(subject.last.cost).to eq 10 }
        it { expect(subject.last.sum_cost).to eq 10 }
      end
    end

    describe 'max height' do
      let(:space) { Gingham::Space.new(5, 5, 3) }
      let(:cell_from) { Gingham::Cell.new(2, 1, 0) }
      let(:direction_from) { Gingham::Direction::D8 }
      let(:wp_from) { Gingham::Waypoint.new(cell_from, direction_from) }
      let(:wp_to) { Gingham::Waypoint.new(cell_to, direction_to) }
      let(:direction_to) { Gingham::Direction::D8 }

      subject { Gingham::PathFinder.find_skill_path(space, wp_from, wp_to, max_height) }

      let(:max_height) { 1 }

      context 'when (2, 1, 0)/8 -> (3, 2, 2)' do
        let(:x2y1d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 1, 0), 8) }
        let(:x2y2d8) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, 1), 8) }
        let(:x2y2d6) { Gingham::Waypoint.new(Gingham::Cell.new(2, 2, 1), 6) }
        let(:cell_to) { Gingham::Cell.new(3, 2, 2) }

        before do
          space.cells[2][1][0].set_ground
          space.cells[2][2][0].set_ground
          space.cells[2][2][1].set_ground
          space.cells[3][2][0].set_ground
          space.cells[3][2][1].set_ground
          space.cells[3][2][2].set_ground
        end

        it { expect(subject.size).to eq 3 }
        it { expect(subject[0]).to eq x2y1d8 }
        it { expect(subject[0].parent).to be_nil }
        it { expect(subject[1]).to eq x2y2d8 }
        it { expect(subject[1].parent).to eq x2y1d8 }
        it { expect(subject[2]).to eq x2y2d6 }
        it { expect(subject[2].parent).to eq x2y2d8 }

        it { expect(subject.last.cost).to eq 5 }
        it { expect(subject.last.sum_cost).to eq 15 }
      end
    end
  end
end

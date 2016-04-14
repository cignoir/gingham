require 'spec_helper'

describe Gingham::Waypoint do
  it 'is defined' do
    expect{ Gingham::Waypoint }.not_to raise_error
  end

  describe 'detect_direction' do
    let(:from) { Gingham::Waypoint.new(cell_from, direction_from) }

    subject { Gingham::Waypoint.detect_direction(from, target_cell) }

    describe 'start_direction' do
      let(:cell_from) { Gingham::Cell.new }
      let(:target_cell) { Gingham::Cell.new }

      context 'when start_direction is D8' do
        let(:direction_from) { Gingham::Direction::D8 }
        it { is_expected.to eq Gingham::Direction::D8 }
      end

      context 'when start_direction is D6' do
        let(:direction_from) { Gingham::Direction::D6 }
        it { is_expected.to eq Gingham::Direction::D6 }
      end

      context 'when start_direction is D4' do
        let(:direction_from) { Gingham::Direction::D4 }
        it { is_expected.to eq Gingham::Direction::D4 }
      end

      context 'when start_direction is D2' do
        let(:direction_from) { Gingham::Direction::D2 }
        it { is_expected.to eq Gingham::Direction::D2 }
      end
    end

    describe 'move cell' do
      let(:cell_from) { Gingham::Cell.new(1, 1, 0) }
      let(:direction_from) { Gingham::Direction::D2 }

      context 'when (1, 1) to (1, 2)' do
        let(:target_cell) { Gingham::Cell.new(1, 2, 1) }
        it { is_expected.to eq Gingham::Direction::D8 }
      end

      context 'when (1, 1) to (2, 1)' do
        let(:target_cell) { Gingham::Cell.new(2, 1, 2) }
        it { is_expected.to eq Gingham::Direction::D6 }
      end

      context 'when (1, 1) to (0, 1)' do
        let(:target_cell) { Gingham::Cell.new(0, 1, 3) }
        it { is_expected.to eq Gingham::Direction::D4 }
      end

      context 'when (1, 1) to (1, 0)' do
        let(:target_cell) { Gingham::Cell.new(1, 0, 4) }
        it { is_expected.to eq Gingham::Direction::D2 }
      end
    end
  end

  describe '#calc_cost' do
    let(:parent_cell) { Gingham::Cell.new(1, 1, 1) }
    let(:parent_direction) { Gingham::Direction::D8 }
    let(:parent_wp) { Gingham::Waypoint.new(parent_cell, parent_direction) }

    let(:cell) { Gingham::Cell.new(1, 1, 1) }
    let(:wp) { Gingham::Waypoint.new(cell, direction, parent_wp) }

    subject { wp.calc_cost }

    context 'in the same cell' do
      context '5/8 -> 5/8' do
        let(:direction) { Gingham::Direction::D8 }
        it { is_expected.to eq 5 }
      end

      context '5/8 -> 5/6' do
        let(:direction) { Gingham::Direction::D6 }
        it { is_expected.to eq 5 }
      end

      context '5/8 -> 5/4' do
        let(:direction) { Gingham::Direction::D4 }
        it { is_expected.to eq 5 }
      end

      context '5/8 -> 5/2' do
        let(:direction) { Gingham::Direction::D2 }
        it { is_expected.to eq 10 }
      end
    end

    context 'when start with direction 8' do
      context 'in the same cell' do
        context '5/8 -> 8/8' do
          let(:cell) { Gingham::Cell.new(1, 2, 1) }
          let(:direction) { Gingham::Direction::D8 }
          it { is_expected.to eq 10 }
        end

        context '5/8 -> 8/6' do
          let(:cell) { Gingham::Cell.new(1, 2, 1) }
          let(:direction) { Gingham::Direction::D6 }
          it { is_expected.to eq 15 }
        end

        context '5/8 -> 8/4' do
          let(:cell) { Gingham::Cell.new(1, 2, 1) }
          let(:direction) { Gingham::Direction::D4 }
          it { is_expected.to eq 15 }
        end

        context '5/8 -> 8/2' do
          let(:cell) { Gingham::Cell.new(1, 2, 1) }
          let(:direction) { Gingham::Direction::D2 }
          it { is_expected.to eq 20 }
        end
      end
    end
  end

  describe '#initialize' do
    let(:parent) { Gingham::Waypoint.new(Gingham::Cell.new(0, 0, 0), Gingham::Direction::D8) }
    let(:cell) { Gingham::Cell.new(0, 1, 8) }
    let(:direction){ Gingham::Direction::D4 }
    let(:wp) { Gingham::Waypoint.new(cell, direction, parent) }

    it 'is instanciated' do
      expect(wp.cell).to eq cell
      expect(wp.direction).to eq 4
      expect(wp.parent).to eq parent
      expect(wp.cost).to eq 15
      expect(wp.sum_cost).to eq 15
    end
  end

  describe '#pick_parents' do
    let(:parent2nd) { Gingham::Waypoint.new(Gingham::Cell.new(0, 0, 0), Gingham::Direction::D4, nil) }
    let(:parent1st) { Gingham::Waypoint.new(Gingham::Cell.new(2, 4, 3), Gingham::Direction::D2, parent2nd) }
    let(:child) { Gingham::Waypoint.new(Gingham::Cell.new(4, 1, 2), Gingham::Direction::D8, parent1st) }

    it 'makes chains' do
      expect(parent2nd.chains).to eq [parent2nd]
      expect(parent1st.chains).to eq [parent2nd, parent1st]
      expect(child.chains).to eq [parent2nd, parent1st, child]
    end
  end

  describe '#turning?' do
    let(:parent) { Gingham::Waypoint.new(parent_cell, Gingham::Direction::D8) }
    let(:wp) { Gingham::Waypoint.new(Gingham::Cell.new(0, 0, 0), Gingham::Direction::D8, parent) }

    subject { wp.turning? }

    context 'when parent is nil' do
      let(:parent) { nil }
      it { is_expected.to be_falsy }
    end

    context 'when parent is not nil' do
      context 'same cell' do
        let(:parent_cell) { Gingham::Cell.new(0, 0, 0) }
        it { is_expected.to be_truthy }
      end
      context 'different cell' do
        let(:parent_cell) { Gingham::Cell.new(2, 3, 0) }
        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#moving?' do
    let(:parent) { Gingham::Waypoint.new(parent_cell, Gingham::Direction::D8) }
    let(:wp) { Gingham::Waypoint.new(Gingham::Cell.new(0, 0, 0), Gingham::Direction::D8, parent) }

    subject { wp.moving? }

    context 'when parent is nil' do
      let(:parent) { nil }
      it { is_expected.to be_falsy }
    end

    context 'when parent is not nil' do
      context 'same cell' do
        let(:parent_cell) { Gingham::Cell.new(0, 0, 0) }
        it { is_expected.to be_falsy }
      end
      context 'different cell' do
        let(:parent_cell) { Gingham::Cell.new(2, 3, 0) }
        it { is_expected.to be_truthy }
      end
    end
  end
end

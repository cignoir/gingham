require 'spec_helper'

describe Gingham::Space do
  it 'is defined' do
    expect { Gingham::Space }.not_to raise_error
  end

  describe '#initialize' do
    let(:space) { Gingham::Space.new(1, 2, 3) }
    it { expect(space.width).to be 1 }
    it { expect(space.depth).to be 2 }
    it { expect(space.height).to be 3 }
    it { expect(space.cells).not_to be_nil }

    it { expect(space.cells[0][0][0]).to be_a Gingham::Cell }
    it { expect { space.cells[1][0][0] }.to raise_error NoMethodError }
    it { expect(space.cells[0][1][0]).to be_a Gingham::Cell }
    it { expect { space.cells[0][2][0] }.to raise_error NoMethodError }
    it { expect(space.cells[0][1][2]).to be_a Gingham::Cell }
    it { expect { space.cells[0][2][3] }.to raise_error NoMethodError }
  end

  describe '#height_at' do
    let(:space) { Gingham::Space.new(1, 1, 3) }

    subject { space.height_at(0, 0) }

    before do
      z = [0, max_height].max
      space.cells[0][0][z].is_ground = true
    end

    context 'when max height is 0' do
      let(:max_height) { 0 }
      it { is_expected.to eq 0 }
    end

    context 'when max height is 1' do
      let(:max_height) { 1 }
      it { is_expected.to eq 1 }
    end

    context 'when max height is 2' do
      let(:max_height) { 2 }
      it { is_expected.to eq 2 }
    end
  end

  describe '#ground_at' do
    let(:space) { Gingham::Space.new(5, 5, 3) }

    before do
      space.cells[2][1][0].is_ground = true
      space.cells[2][2][0].is_ground = true
      space.cells[2][2][1].is_ground = true
      space.cells[3][2][0].is_ground = true
      space.cells[3][2][1].is_ground = true
      space.cells[3][2][2].is_ground = true
    end

    it { expect(space.ground_at(2, 1)).to eq Gingham::Cell.new(2, 1, 0) }
    it { expect(space.ground_at(2, 2)).to eq Gingham::Cell.new(2, 2, 1) }
    it { expect(space.ground_at(3, 2)).to eq Gingham::Cell.new(3, 2, 2) }
  end

  describe '#rotate_right' do
    let(:space) { Gingham::Space.new(5, 5, 1) }
    let(:center) { space.cells[2][2][0] }
    let(:target) { space.cells[2][4][0] }
    it { expect(space.rotate_right(center, target)).to eq space.cells[4][2][0] }
  end

  describe '#rotate_left' do
    let(:space) { Gingham::Space.new(5, 5, 1) }
    let(:center) { space.cells[2][2][0] }
    let(:target) { space.cells[2][4][0] }
    it { expect(space.rotate_left(center, target)).to eq space.cells[0][2][0] }
  end

  describe '#rotate_reverse' do
    let(:space) { Gingham::Space.new(5, 5, 1) }
    let(:center) { space.cells[2][2][0] }
    let(:target) { space.cells[2][4][0] }
    it { expect(space.rotate_reverse(center, target)).to eq space.cells[2][0][0] }
  end

  describe '#build_range_cell' do
    let(:space) { Gingham::Space.new(9, 9, 1) }
    let(:waypoint) { Gingham::Waypoint.new(space.cells[4][4][0], direction) }

    subject { space.build_range_cell(waypoint, query) }

    context 'when direction is 8' do
      let(:direction) { Gingham::Direction::D8 }

      context 'and query is 88' do
        let(:query) { 88 }
        it { is_expected.to eq space.cells[4][6][0] }
      end

      context 'and query is 8866' do
        let(:query) { 8866 }
        it { is_expected.to eq space.cells[6][6][0] }
      end

      context 'and query is 88888' do
        let(:query) { 88888 }
        it { is_expected.to be_nil }
      end
    end

    context 'when direction is 6' do
      let(:direction) { Gingham::Direction::D6 }

      context 'and query is 88' do
        let(:query) { 88 }
        it { is_expected.to eq space.cells[6][4][0] }
      end

      context 'and query is 8866' do
        let(:query) { 8866 }
        it { is_expected.to eq space.cells[6][2][0] }
      end

      context 'and query is 88888' do
        let(:query) { 88888 }
        it { is_expected.to be_nil }
      end
    end

    context 'when direction is 4' do
      let(:direction) { Gingham::Direction::D4 }

      context 'and query is 88' do
        let(:query) { 88 }
        it { is_expected.to eq space.cells[2][4][0] }
      end

      context 'and query is 8866' do
        let(:query) { 8866 }
        it { is_expected.to eq space.cells[2][6][0] }
      end

      context 'and query is 88888' do
        let(:query) { 88888 }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#build_all_range_cells' do
    let(:space) { Gingham::Space.new(9, 9, 1) }
    let(:waypoint) { Gingham::Waypoint.new(space.cells[4][4][0], direction) }

    subject { space.build_all_range_cells(waypoint, query_list) }

    context 'when direction is 8' do
      let(:direction) { Gingham::Direction::D8 }

      context 'and query_list is [8, 6, 4, 2]' do
        let(:query_list) { [8, 6, 4, 2] }
        it { expect(subject.size).to eq 4 }
        it { is_expected.to include space.cells[4][5][0] }
        it { is_expected.to include space.cells[4][3][0] }
        it { is_expected.to include space.cells[5][4][0] }
        it { is_expected.to include space.cells[3][4][0] }
      end

      context 'and query_list is [8888, 66, 66, 2, 44, 2]' do
        let(:query_list) { [8888, 66, 44, 2] }
        it { expect(subject.size).to eq 4 }
        it { is_expected.to include space.cells[4][8][0] }
        it { is_expected.to include space.cells[6][4][0] }
        it { is_expected.to include space.cells[2][4][0] }
        it { is_expected.to include space.cells[4][3][0] }
      end
    end

    context 'when direction is 2' do
      let(:direction) { Gingham::Direction::D2 }

      context 'and query_list is [8888, 66, 44, 2, 44]' do
        let(:query_list) { [8888, 66, 44, 2] }
        it { expect(subject.size).to eq 4 }
        it { is_expected.to include space.cells[4][0][0] }
        it { is_expected.to include space.cells[6][4][0] }
        it { is_expected.to include space.cells[2][4][0] }
        it { is_expected.to include space.cells[4][5][0] }
      end
    end
  end
end

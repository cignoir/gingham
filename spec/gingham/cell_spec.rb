require 'spec_helper'

describe Gingham::Cell do
  it 'is defined' do
    expect{ Gingham::Cell }.not_to raise_error
  end

  describe '#occupied? and #passable?' do
    let(:cell) { Gingham::Cell.new }

    context 'when cell is occupied' do
      before { cell.is_occupied = true }

      it 'returns a flag correctly' do
        expect(cell).to be_occupied
        expect(cell).not_to be_passable
      end
    end

    context 'when cell is not occupied' do
      before { cell.is_occupied = false }

      it 'returns a flag correctly' do
        expect(cell).not_to be_occupied
        expect(cell).to be_passable
      end
    end
  end

  describe '#ground? and #sky?' do
    let(:cell) { Gingham::Cell.new }

    context 'when cell is ground' do
      before { cell.is_ground = true }

      it 'returns a flag correctly' do
        expect(cell).to be_ground
        expect(cell).not_to be_sky
      end
    end

    context 'when cell is not occupied' do
      before { cell.is_ground = false }

      it 'returns a flag correctly' do
        expect(cell).not_to be_ground
        expect(cell).to be_sky
      end
    end
  end
end

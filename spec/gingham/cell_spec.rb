require 'spec_helper'

describe Gingham::Cell do
  it 'is defined' do
    expect{ Gingham::Cell }.not_to raise_error
  end

  describe '#occupied?' do
    let(:cell) { Gingham::Cell.new }

    context 'when cell is occupied' do
      before { cell.is_occupied = true }
      it { expect(cell.occupied?).to be_truthy }
    end

    context 'when cell is not occupied' do
      before { cell.is_occupied = false }
      it { expect(cell.occupied?).to be_falsy }
    end
  end
end

require 'spec_helper'

describe Gingham::Position do
  it 'is defined' do
    expect{ Gingham::Position }.not_to raise_error
  end

  describe '#initialize' do
    let(:pos) { Gingham::Position.new(1, 2, 3) }

    it 'should be initialized' do
      expect(pos.x).to eq 1
      expect(pos.y).to eq 2
      expect(pos.z).to eq 3
    end
  end
end

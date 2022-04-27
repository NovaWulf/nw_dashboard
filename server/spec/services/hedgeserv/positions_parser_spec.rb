RSpec.describe Hedgeserv::PositionsParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with transactions' do
    let(:filename) { 'sample_positions.csv' }
    it 'returns grouped by Strategy' do
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 5 # 4 strategies and totals
    end

    it 'shows total' do
      expect(result[0][0]).to include 'Total'
      expect(result[0][3]).to include '($799)'
    end

    it 'groups data' do
      expect(result[1][0]).to include 'Liquid digital assets'
      expect(result[1][3]).to include '$44'

      expect(result[2][0]).to include 'Long / short'
      expect(result[2][1]).to include '$28'
    end
  end
end

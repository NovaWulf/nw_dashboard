RSpec.describe Hedgeserv::PositionsParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with positions' do
    let(:filename) { 'sample_positions.csv' }

    it 'returns grouped by Strategy' do
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 6 # 5 strategies and totals
    end

    it 'shows total' do
      expect(result[0][0]).to include 'Total'
      expect(result[0][3]).to include '(4,763)'
      expect(result[0][3]).to include '-13.0%'
    end

    it 'groups data' do
      expect(result[1][0]).to include 'Liquid Digital Assets'
      expect(result[1][3]).to include '(109)'

      expect(result[2][0]).to include 'Long / Short Public Securities'
      expect(result[2][1]).to include '127'
    end

    it 'shows percent of fund' do
      expect(result[1][0]).to include '2.7%'
    end
  end
end

RSpec.describe Hedgeserv::PositionsParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with transactions' do
    let(:filename) { 'sample_positions2.csv' }
    it 'returns grouped by Strategy' do
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 6 # 5 strategies and totals
    end

    it 'shows total' do
      expect(result[0][0]).to include 'Total'
      expect(result[0][3]).to include '(2,816)'
      expect(result[0][3]).to include '-8.8%'
    end

    it 'groups data' do
      expect(result[1][0]).to include 'Liquid digital assets'
      expect(result[1][3]).to include '(180)'

      expect(result[3][0]).to include 'Long / short'
      expect(result[3][1]).to include '102'
    end
  end
end

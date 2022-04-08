RSpec.describe Hedgeserv::PositionsParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with transactions' do
    let(:filename) { 'NWDM_Positions.csv' }
    it 'returns grouped by Strategy' do
      puts result
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 4 # 4 strategies
    end

    it 'groups data' do
      expect(result[0][0]).to include 'Liquid digital assets'
      expect(result[0][3]).to include '$44,890.27'

      expect(result[1][0]).to include 'Long / short'
      expect(result[1][1]).to include '$28,975.65'
    end
  end
end

RSpec.describe Hedgeserv::WinnersParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with positions' do
    let(:filename) { 'sample_positions2.csv' }

    it 'returns daily, mtd and ytd losers and winners' do
      expect(result).to be_an_instance_of(Hash)
      expect(result.keys.count).to eql 6
    end

    it 'shows name, value and percent' do
      expect(result[:daily_winners][0][0]).to include 'MSTR'
      expect(result[:daily_winners][0][1]).to include '66'
      expect(result[:daily_winners][0][1]).to include '7.0%'
    end

    it 'sorts' do
      expect(result[:daily_losers][0][0]).to include 'SI US EQUITY'
    end
  end
end

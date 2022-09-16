RSpec.describe Hedgeserv::WinnersParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with positions' do
    let(:filename) { 'sample_positions.csv' }

    it 'returns daily, mtd and ytd losers and winners' do
      expect(result).to be_an_instance_of(Hash)
      expect(result.keys.count).to eql 6
    end

    it 'shows name, value and contribution to fund' do
      expect(result[:daily_winners][0][0]).to include 'Bitcoin'
      expect(result[:daily_winners][0][1]).to include '13'
      expect(result[:daily_winners][0][1]).to include '0.1%'
    end

    it 'sorts' do
      expect(result[:daily_losers][0][0]).to include 'MicroStrategy'
    end

    it 'groups data' do
      expect(result[:ytd_losers][0][0]).not_to equal result[:ytd_losers][0][1]
    end
  end
end

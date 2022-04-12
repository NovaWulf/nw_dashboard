RSpec.describe Hedgeserv::TradeParser do
  let(:csv_text) { file_fixture(filename).read }
  subject { described_class.run(csv_text: csv_text) }
  let(:result) { subject.value }

  context 'file with transactions' do
    let(:filename) { 'NWDM_NovawulfTransactions_for_20220325-20220325_run_20220330_at_175321.csv' }
    it 'returns translated rows' do
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 4 # 4 trades no header
    end

    it 'handles shorts' do
      expect(result[0]).to include 'NovaWulf Digital Master Fund L.P. shorted 4,500 shares of PROSHARES BITCOIN STRATEGY E at $27.77 for a total of $124,833.41'
    end

    it 'handles options' do
      expect(result[1]).to include 'NovaWulf Digital Master Fund L.P. shorted 120 options of RIOT US 06/17/22 C30 at $1.28 for a total of $15,115.76'
    end

    it 'handles equities' do
      expect(result[2]).to include 'NovaWulf Digital Master Fund L.P. bought 12,100 shares of RIOT BLOCKCHAIN INC at $20.64 for a total of $250,148.14'
    end
  end

  context 'empty file' do
    let(:filename) { 'NWDM_NovawulfTransactions_empty.csv' }

    it 'only returns a header' do
      expect(result).to be_an_instance_of(Array)
      expect(result.count).to eql 1 #  header
      expect(result[0]).to include 'no trades'
    end
  end
end

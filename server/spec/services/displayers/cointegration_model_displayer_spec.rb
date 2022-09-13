RSpec.describe Displayers::CointegrationModelDisplayer do
  subject { described_class }

  before(:each) do
    CointegrationModel.create(
      uuid: 'id1',
      timestamp: 1_800_000_000,
      ecdet: 'const',
      spec: 'transitory',
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: Time.now.to_i,
      model_endtime: 1_700_000_000,
      in_sample_mean: 0,
      in_sample_sd: 3,
      log_prices: true
    )
    CointegrationModel.create(
      uuid: 'id2',
      timestamp: 1_800_000_000,
      ecdet: 'const',
      spec: 'transitory',
      cv_10_pct: 6,
      cv_5_pct: 7,
      cv_1_pct: 8,
      test_stat: 9,
      top_eig: 0.0008,
      resolution: 60,
      model_starttime: Time.now.to_i,
      model_endtime: 1_700_000_000,
      in_sample_mean: 0,
      in_sample_sd: 3,
      log_prices: true
    )
    BacktestModel.create(
      version: 1,
      model_id: 'id1',
      sequence_number: 0,
      name: 'seed_model',
      basket: 'OP_ETH'
    )
    BacktestModel.create(
      version: 1,
      model_id: 'id2',
      sequence_number: 1,
      name: 'model2',
      basket: 'OP_ETH'
    )
  end

  it 'returns prices' do
    result = subject.run(version: 1,sequence_number:0,basket: "OP_ETH").value
    expect(subject.run(version: 1,sequence_number:0,basket: "OP_ETH").value.first["uuid"]).to eql "id1"
    expect(subject.run(version: 1,sequence_number:nil,basket: "OP_ETH").value.first["uuid"]).to eql "id2"
  end
end

task get_recent_data: :environment do
  tracked_tokens = %w[btc eth sol luna avax near ada]
  tracked_tokens.each do |t|
    Fetchers::EcosystemRepoFetcher.run(token: t)
    Fetchers::PriceDataFetcher.run(token: t)
    Fetchers::ActiveAddressesFetcher.run(token: t)
    Fetchers::TransactionCountFetcher.run(token: t)
    Fetchers::VolumeFetcher.run(token: t)
    Fetchers::DevActivityFetcher.run(token: t)
    Fetchers::CirculatingSupplyFetcher.run(token: t)
    Fetchers::MarketCapDominanceFetcher.run(token: t)
  end

  # GithubActivityFetcher.run
  Fetchers::RhodlFetcher.run
  MvrvCalculator.run
  JesseCalculator.run
  Fetchers::SolanaActiveAddressesFetcher.run
  Fetchers::SolanaTransactionCountFetcher.run
  Fetchers::AvalancheTransactionFetcher.run
  %w[btc eth].each do |t|
    Fetchers::TransactionFeeFetcher.run(token: t)
  end
  %w[sol avax near].each do |t|
    Fetchers::TransactionFeeTokenTerminalFetcher.run(token: t)
  end
  Fetchers::EthereumSmartContractUsageFetcher.run

  tracked_dapps = %w[aave uni crv snx]
  tracked_dapps.each do |t|
    Fetchers::PriceDataFetcher.run(token: t)
    Fetchers::ActiveAddressesFetcher.run(token: t)
    Fetchers::TransactionCountFetcher.run(token: t)
    Fetchers::TransactionFeeTokenTerminalFetcher.run(token: t)
    Fetchers::TvlFetcher.run(token: t)
    Fetchers::CirculatingSupplyFetcher.run(token: t)
    Fetchers::FullyDilutedMarketCapFetcher.run(token: t)
  end
end

task backfill_github_data: :environment do
  # this runs every 10 mins, and github's rate limit is 5000/hr
  # so we don't want to make more than 833 calls in here
  # each backfill makes about 220 calls (4.3 years x 52 weeks), so we estimate we can do roughly 4 times
  4.times { GithubBackfiller.run }
end

task fetch_github_data: :environment do
  repos = Repo.healthy.canonical.least_recently_fetched.first(1000)
  repos.each { |r| Fetchers::GithubActivityFetcher.run(repo: r) }
end

task :fetch_token_github_data, [:token] => [:environment] do |_t, args|
  repos = Repo.healthy.canonical.by_token(args[:token])
  repos.each { |r| Fetchers::GithubActivityFetcher.run(repo: r) }
end

task hedgeserv_email: :environment do
  Hedgeserv::DailyProcessor.run
end

task update_arb_signal: :environment do
  tracked_pairs = %w[eth-usd op-usd btc-usd uni-usd snx-usd crv-usd]
  tracked_pairs.each do |p|
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  baskets = %w[OP_ETH UNI_ETH BTC_ETH SNX_ETH CRV_ETH]
  baskets.each do |b|
    mu = ModelUpdate.new(basket: b)
    mu.seed
    ArbitrageCalculator.run(version: 2, silent: true, basket: b, seq_num: nil)
    Backtester.run(version: 2, basket: b, seq_num: nil)
  end
end

task rerun_backtest: :environment do
  model_to_replace = BacktestModel.where(model_id: ENV['model']).last
  version = model_to_replace&.version
  seq_num = model_to_replace&.sequence_number
  basket = model_to_replace&.basket
  puts "seq_num: #{seq_num}"
  if ENV['skip'] == 'y'
    Rails.Logger.info 'deleting backtest and positions and recalculating. not deleting signal, skipping recalculation of it'
    ModeledSignal.where("model_id like '%#{ENV['model']}-%'").destroy_all
  else
    Rails.logger.info 'deleting signal, backtest, and positions, and recalculating'
    ModeledSignal.where("model_id like '%#{ENV['model']}%'").destroy_all
    ArbitrageCalculator.run(version: version, silent: true, basket: basket, seq_num: seq_num)
  end
  Backtester.run(version: version, basket: basket, seq_num: seq_num)
end

task try_update_models: :environment do
  if Time.now.sunday?
    tracked_pairs = %w[eth-usd op-usd btc-usd uni-usd snx-usd crv-usd cvx-usd]
    tracked_pairs.each do |p|
      Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
    end
    Rails.logger.info 'writing candle data to CSV...'
    baskets = %w[OP_ETH UNI_ETH BTC_ETH SNX_ETH CVX_CRV]
    baskets.each do |b|
      mu = ModelUpdate.new(basket: b)
      mu.update_model(version: 2, max_weeks_back: 10, min_weeks_back: 5, interval_mins: 1440)
    end
    JesseModelUpdate.run
  end
end

task try_update_model_as_of: :environment do
  tracked_pairs = %w[eth-usd op-usd btc-usd uni-usd snx-usd]
  tracked_pairs.each do |p|
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  Rails.logger.info 'writing candle data to CSV...'
  mu = ModelUpdate.new(basket: ENV['basket'])
  mu.update_model(version: 2, max_weeks_back: 8, min_weeks_back: 3, interval_mins: 1440, as_of_date: ENV['end'])
end

task add_model_with_dates: :environment do
  tracked_pairs = %w[eth-usd op-usd btc-usd uni-usd snx-usd]
  tracked_pairs.each do |p|
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  Rails.logger.info 'writing candle data to CSV...'
  mu = ModelUpdate.new(basket: ENV['basket'])
  mu.add_model_with_dates(version: 2, start_time_string: ENV['start'], end_time_string: ENV['end'])
end

task jesse_model_update: :environment do
  JesseModelUpdate.run
end

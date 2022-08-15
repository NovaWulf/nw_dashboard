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
  tracked_pairs = %w[eth-usd op-usd btc-usd uni-usd snx-usd]
  tracked_pairs.each do |p|
    puts "getting pair #{p}"
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  Rails.logger.info 'writing candle data to CSV...'
  puts 'writing candle data to CSV...'
  mu = ModelUpdate.new(basket: 'UNI-ETH')
  mu.seed
  ArbitrageCalculator.run(version: MODEL_VERSION, silent: true)
  Rails.logger.info 'arbitrage calculator complete for seed model'
  Backtester.run(version: MODEL_VERSION)
  Rails.logger.info 'backtester complete for seed model'
end

task try_update_models: :environment do
  if Time.now.sunday?
    tracked_pairs = %w[eth-usd op-usd]
    tracked_pairs.each do |p|
      Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
    end
    Rails.logger.info 'writing candle data to CSV...'
    CsvWriter.run
    mu = ModelUpdate.new(basket: 'OP_ETH')
    mu.update_model(version: 2, max_weeks_back: 8, min_weeks_back: 3, interval_mins: 1440)
    mu.update_jesse_model
  end
end

task try_update_model_as_of: :environment do
  tracked_pairs = %w[eth-usd op-usd]
  tracked_pairs.each do |p|
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  Rails.logger.info 'writing candle data to CSV...'
  CsvWriter.run(table: 'candles')
  mu = ModelUpdate.new(basket: 'OP_ETH')
  puts ENV['as_of_date']
  mu.update_model(version: 2, max_weeks_back: 8, min_weeks_back: 3, interval_mins: 1440, as_of_date: ENV['as_of_date'])
end

task add_model_with_dates: :environment do
  tracked_pairs = %w[eth-usd op-usd]
  tracked_pairs.each do |p|
    Fetchers::CoinbaseFetcher.run(resolution: 60, pair: p)
  end
  Rails.logger.info 'writing candle data to CSV...'
  CsvWriter.run(table: 'candles')
  mu = ModelUpdate.new(basket: 'OP_ETH')
  mu.add_model_with_dates(version: 2, start_time_string: ENV['start'], end_time_string: ENV['end'])
end

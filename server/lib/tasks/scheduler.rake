task get_recent_data: :environment do
  PriceDataFetcher.run(token: 'btc')
  PriceDataFetcher.run(token: 'eth')
  PriceDataFetcher.run(token: 'sol')
  PriceDataFetcher.run(token: 'luna')
  PriceDataFetcher.run(token: 'avax')

  ActiveAddressesFetcher.run(token: 'eth')
  ActiveAddressesFetcher.run(token: 'btc')
  ActiveAddressesFetcher.run(token: 'sol')
  ActiveAddressesFetcher.run(token: 'luna')
  ActiveAddressesFetcher.run(token: 'avax')

  DevActivityFetcher.run(token: 'eth')
  DevActivityFetcher.run(token: 'btc')
  DevActivityFetcher.run(token: 'sol')
  DevActivityFetcher.run(token: 'luna')
  DevActivityFetcher.run(token: 'avax')

  RhodlFetcher.run

  MvrvCalculator.run
  JesseCalculator.run

  TrendsImporter.run(path: 'https://gist.githubusercontent.com/iamnader/03b2da71d50c3cdeee4772ba66aeff2e/raw/812c4fa646908fc5f991312b7b75d6dadb2197da/bitcoin_trends')
end

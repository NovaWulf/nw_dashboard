task get_recent_data: :environment do
  PriceDataFetcher.run(token: 'btc')
  PriceDataFetcher.run(token: 'eth')
  PriceDataFetcher.run(token: 'sol')
  PriceDataFetcher.run(token: 'luna')

  MvrvCalculator.run

  ActiveAddressesFetcher.run(token: 'eth')
  ActiveAddressesFetcher.run(token: 'btc')
  ActiveAddressesFetcher.run(token: 'sol')
  ActiveAddressesFetcher.run(token: 'luna')

  DevActivityFetcher.run(token: 'eth')
  DevActivityFetcher.run(token: 'btc')
  DevActivityFetcher.run(token: 'sol')
  DevActivityFetcher.run(token: 'luna')

  RhodlFetcher.run(token: 'btc')
end

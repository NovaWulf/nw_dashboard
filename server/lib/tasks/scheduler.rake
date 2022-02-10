task get_recent_data: :environment do
  PriceDataFetcher.run(token: 'btc')
  PriceDataFetcher.run(token: 'eth')
  MvrvCalculator.run
  BtcActiveAddressesFetcher.run
  DevActivityFetcher.run(token: 'eth')
  DevActivityFetcher.run(token: 'btc')
end

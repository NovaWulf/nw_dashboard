task get_recent_data: :environment do
  BtcPriceDataFetcher.run
  MvrvCalculator.run
end

task get_recent_data: :environment do
  tracked_tokens = %w(btc eth sol luna avax near)
  tracked_tokens.each do |t|
    EcosystemRepoFetcher.run(token: t)
    PriceDataFetcher.run(token: t)
    ActiveAddressesFetcher.run(token: t)
    # DevActivityFetcher.run(token: t)
  end

  GithubActivityFetcher.run
  
  RhodlFetcher.run

  MvrvCalculator.run
  JesseCalculator.run
end

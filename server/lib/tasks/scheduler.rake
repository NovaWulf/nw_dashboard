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

task backfill_github_data: :environment do 
  # this runs every 10 mins, and github's rate limit is 5000
  # each run makes about 200 calls, so we estimate we can do this 4 times
  4.times { GithubBackfiller.run }
end

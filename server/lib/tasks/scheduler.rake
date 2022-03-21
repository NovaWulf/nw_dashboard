task get_recent_data: :environment do
  tracked_tokens = %w[btc eth sol luna avax near]
  tracked_tokens.each do |t|
    EcosystemRepoFetcher.run(token: t)
    PriceDataFetcher.run(token: t)
    ActiveAddressesFetcher.run(token: t)
    VolumeFetcher.run(token: t)
    # DevActivityFetcher.run(token: t)
  end

  # GithubActivityFetcher.run
  RhodlFetcher.run
  MvrvCalculator.run
  JesseCalculator.run
end

task backfill_github_data: :environment do
  # this runs every 10 mins, and github's rate limit is 5000/hr
  # so we don't want to make more than 833 calls in here
  # each backfill makes about 220 calls (4.3 years x 52 weeks), so we estimate we can do roughly 4 times
  4.times { GithubBackfiller.run }
end

task fetch_github_data: :environment do
  repos = Repo.healthy.least_recently_fetched.first(1000)
  repos.each { |r| GithubActivityFetcher.run(repo: r) }
end

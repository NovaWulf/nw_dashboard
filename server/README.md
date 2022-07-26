# README

## Getting Started

- Dependencies are Postgres and R
- You'll need the version of ruby specified in `.ruby-version`
- `rake db:setup` && `bundle install`
- Ask another developer for a copy of `.env.local` which has api keys for services

## Data Fetching

`rake get_recent_data` will pull in most of the data needed for charts

Arbitrage data + model pipeline:

- In order to download recent candles, run `rake download_candles`

- Next update the model by running `rake cointegration_analysis`

- Finally run `rake update_arb_signal`

* ...

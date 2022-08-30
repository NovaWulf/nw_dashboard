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

## model updating:

- In order to update the model as of the current date, run `rake try_update_models`
- If you want to update the model as of a certain date (with optimization for start date), run `rake try_update_model_as_of as_of_date="%Y-%m-%d" basket=<basket>`
- If you want to add a model with a specific start and end date to backtest models, run `rake add_model_with_dates start="'%Y-%m-%d'" end="'%Y-%m-%d'" basket=<basket>`
  where <basket> above could be for example: "OP_ETH" or "UNI_ETH".

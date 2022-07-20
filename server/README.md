# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

Arbitrage data  + model pipeline:
- In order to download recent candles, run `rake download_candles`

- Next update the model by running `rake cointegration_analysis`

- Finally run `rake update_arb_signal`

* ...

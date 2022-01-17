# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Metric.count.zero?

  BtcDataFetcher.run

  puts 'Fetching circulating mcap'
  mc = Messari.new.all_circulating_marketcap
  mc_vals = mc.parsed_response['data']['values']
  puts 'Saving circulating mcap'
  mc_vals.each { |m| Metric.create(timestamp: Time.at(m[0] / 1000).to_date, value: m[1], name: 'btc_circ_mcap') }

  puts 'Fetching realized mcap'
  rmc = Messari.new.all_realized_marketcap
  rmc_vals = rmc.parsed_response['data']['values']

  puts 'Saving realized mcap'
  rmc_vals.each do |m|
    Metric.create(timestamp: Time.at(m[0] / 1000).to_date, value: m[1], name: 'btc_realized_mcap')
  end

  puts 'Storing MVRV'
  mc_vals.each_with_index do |cm, idx|
    if rmc_vals[idx].nil?
      puts "couldn't find realized mcap for idx #{idx}"
      next
    end

    v = cm[1] / rmc_vals[idx][1]
    Metric.create(timestamp: Time.at(cm[0] / 1000).to_date, value: v, name: 'btc_mvrv')
  end

end

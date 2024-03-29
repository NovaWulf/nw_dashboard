# frozen_string_literal: true

class NotificationMailerPreview < ActionMailer::Preview
  def notification
    NotificationMailer.with(
      subject: 'MVRV Alert',
      text: 'MVRV just crossed 2.75 with a value of 2.78.'
    ).notification
  end

  def daily_hedgeserv
    trades_file = File.read(Rails.root.join('spec', 'fixtures', 'files', 'sample_trades.csv'))
    trades = Hedgeserv::TradeParser.run(csv_text: trades_file).value
    positions_file = File.read(Rails.root.join('spec', 'fixtures', 'files', 'sample_positions.csv'))
    positions = Hedgeserv::PositionsParser.run(csv_text: positions_file).value
    winners = Hedgeserv::WinnersParser.run(csv_text: positions_file).value

    NotificationMailer.with(run_date: Date.today, trades: trades, positions: positions, winners: winners).daily_trades
  end

  def daily_hedgeserv_with_approval
    trades_file = File.read(Rails.root.join('spec', 'fixtures', 'files', 'sample_trades.csv'))
    trades = Hedgeserv::TradeParser.run(csv_text: trades_file).value
    positions_file = File.read(Rails.root.join('spec', 'fixtures', 'files', 'sample_positions.csv'))
    positions = Hedgeserv::PositionsParser.run(csv_text: positions_file).value
    winners = Hedgeserv::WinnersParser.run(csv_text: positions_file).value

    NotificationMailer.with(to_address: 'mike@novawulf.io', run_date: Date.today, trades: trades, positions: positions,
                            winners: winners).daily_trades
  end
end

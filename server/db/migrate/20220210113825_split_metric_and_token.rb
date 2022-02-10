class SplitMetricAndToken < ActiveRecord::Migration[6.1]
  def change
    add_column :metrics, :token, :string
    add_column :metrics, :metric, :string
    Metric.where(name: 'btc_price').update_all(metric: 'price', token: 'btc')
    Metric.where(name: 'btc_active_addresses').update_all(metric: 'active_addresses', token: 'btc')
    Metric.where(name: 'btc_circ_mcap').update_all(metric: 'circ_mcap', token: 'btc')
    Metric.where(name: 'btc_realized_mcap').update_all(metric: 'realized_mcap', token: 'btc')
    Metric.where(name: 'btc_mvrv').update_all(metric: 'mvrv', token: 'btc')

    remove_column :metrics, :name, :string
  end
end

class PriceProcessor < BaseService
  attr_reader :asset_names, :start_time, :end_time

  def initialize(asset_names, start_time = nil, end_time = nil)
    @asset_names = asset_names
    @start_time = start_time
    @end_time = end_time
  end

  def run
    puts "asset_names: #{asset_names}"
    if asset_names.length != 2
      abort("price processor currently only works with 2 assets. you are trying to merge #{asset_names.length} asset timeseries")
    end
    asset_aliases = asset_names.map { |e| e.gsub('-', '_') }
    sql = "Select
    t1.starttime as starttime,
    t1.close as #{asset_aliases[0]},
    t2.close as #{asset_aliases[1]}
    from candles t1
    full outer join candles t2
    on t1.starttime=t2.starttime
    and t1.pair='#{asset_names[0]}' and t2.pair='#{asset_names[1]}'
    where t1.pair='#{asset_names[0]}' or t2.pair='#{asset_names[1]}'
    order by t1.starttime asc
    "
    puts "start time in price processor: #{start_time}"
    records_array = ActiveRecord::Base.connection.execute(sql)
    puts "number of records in processor (left join): #{records_array.count}"
    starttimes = records_array.pluck('starttime')
    prices = asset_aliases.map { |a| records_array.pluck(a) }

    for i in 0..50
      puts "start time: #{records_array[i]['starttime']} eth price:  + #{records_array[i]['eth_usd']}  op price: #{records_array[i]['op_usd']}"
    end
    if end_time
      end_index = starttimes.index(end_time)
      starttimes = starttimes[0..end_index]
      for i in 0..1
        prices[i] = prices[i][0..end_index]
      end
    end

    new_len = starttimes.count
    if start_time
      start_index = starttimes.index(start_time)
      starttimes = starttimes[start_index..(new_len - 1)]
      for i in 0..1
        prices[i] = prices[i][start_index..(new_len - 1)]
      end
    end

    [starttimes, prices]
  end
end

class PriceProcessor
  def run(asset_names, start_time = nil, end_time = nil)
    asset_aliases = asset_names.map { |e| e.gsub('-', '_') }
    sql = "Select
    t1.starttime as starttime,
    t1.close as #{asset_aliases[0]},
    t2.close as #{asset_aliases[1]}
    from candles t1
    inner join candles t2
    on t1.starttime=t2.starttime
    where t1.pair='#{asset_names[0]}' and t2.pair='#{asset_names[1]}'
    order by t1.starttime asc
    "

    records_array = ActiveRecord::Base.connection.execute(sql)
    starttimes = records_array.pluck('starttime')
    prices = asset_aliases.map { |a| records_array.pluck(a) }

    if start_time && end_time
      start_index = starttimes.index(start_time)
      end_index = starttimes.index(end_time)
      starttimes = starttimes[start_index..end_index]
      for i in 0..1
        prices[i] = prices[i][start_index..end_index]
      end
    end
    [starttimes, prices]
  end
end

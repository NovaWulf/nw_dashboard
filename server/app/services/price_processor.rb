class PriceProcessor
  def run(asset_names, start_time = nil, end_time = nil)
    puts 'asset names array: ' + asset_names.to_s
    asset_aliases = asset_names.map { |e| e.gsub('-', '_') }
    puts 'asset_aliases: ' + asset_aliases.to_s
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
    if start_time && end_time
      records_array = records_array.where("starttime >= #{start_time} and starttime <= #{end_time}")
    end
    prices = asset_aliases.map { |a| records_array.pluck(a) }
    starttimes = records_array.pluck('starttime')
    [starttimes, prices]
  end
end

def dev_activity(token)
  Metric.by_token(token).by_metric('dev_activity').group_by_month(:timestamp).sum(:value).to_a.each do |m|
    puts m[1].to_s
  end
end

def active(token)
  Metric.by_token(token).by_metric('active_addresses').sundays.oldest_first.each do |m|
    puts m.value.to_s
  end
end

def dev_activity(token)
  RepoCommit.by_token(token).group_by_month(:day, time_zone: false).sum(:count).to_a.each do |m|
    puts m[1].to_s
  end
end

columns_that_make_record_distinct = %i[user name]
distinct_records = Repo.select('MIN(id) as id').group(columns_that_make_record_distinct)
duplicate_records = Repo.where.not(id: distinct_records)

ids = Repo.where(user: 'terra-project').map(&:id)
Repo.where(id: ids).update(user: 'terra-money', backfilled_at: nil)
RepoCommit.where(repo_id: ids).destroy

repos = Repo.where(user: 'terra-project')
repos.each do |r|
  r.update(user: 'terra-money', backfilled_at: nil)
  r.repo_commits.destroy
rescue ActiveRecord::RecordNotUnique
  r.destroy
end

dupe_ids = RepoCommit.group(:repo_id, :day).having('count(*) > 1').select('unnest((array_agg("id"))[2:])')
RepoCommit.where(id: dupe_ids)

Metric.by_token('btc').by_metric('active_addresses').each do |m|
  m.delete unless m.timestamp.monday?
end

def token_activity_detail(token)
  repos = Repo.by_token(token).healthy.canonical
  header = ['Repo', *repos.first.repo_commits.map(&:day).sort]
  csv_string = CSV.generate do |csv|
    csv << header
    repos.each do |r|
      csv << ["https://github.com/#{r.description}", *r.repo_commits.sort_by { |c| c.day }.map(&:count)]
    end
  end
  puts csv_string
end

Repo.healthy.each do |r|
  RepoCanonicalizer.run(repo: r)
end


    def dev_activity(token)
        Metric.by_token(token).by_metric('dev_activity').group_by_month(:timestamp).sum(:value).to_a.each do |m|
         puts m[1].to_s
        end
      end

      def active(token)
        Metric.by_token(token).by_metric('active_addresses').mondays.oldest_first.each do |m|
            puts m.value.to_s
        end
      end
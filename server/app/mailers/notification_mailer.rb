class NotificationMailer < ApplicationMailer
  def notification
    @subject = params[:subject]
    @text = Array(params[:text])
    to_address = ENV['NOTIFICATIONS_EMAIL'] || 'test@example.com'
    mail(to: to_address, subject: @subject)
  end

  def daily_trades
    @subject = params[:subject]
    @trades = Array(params[:trades])
    @positions = Array(params[:positions])
    @winners = params[:winners]
    @run_date = params[:run_date]
    @to_add = params[:to_address] || ENV['NOTIFICATIONS_EMAIL'] || 'test@example.com'
    @approval_email = ['mike@novawulf.io', 'jason@novawulf.io'].include?(@to_add)

    mail(to: @to_add, subject: @subject)
  end
end

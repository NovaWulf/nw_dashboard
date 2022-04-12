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
    to_address = ENV['NOTIFICATIONS_EMAIL'] || 'test@example.com'
    mail(to: to_address, subject: @subject)
  end
end

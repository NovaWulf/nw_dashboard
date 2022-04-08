class NotificationMailer < ApplicationMailer
  def notification
    @subject = params[:subject]
    @text = Array(params[:text])
    to_address = Rails.env.production? ? 'all@novawulf.io' : 'iamnader@gmail.com'
    mail(to: to_address, subject: @subject)
  end

  def daily_trades
    @subject = params[:subject]
    @trades = Array(params[:trades])
    @positions = Array(params[:positions])
    to_address = Rails.env.production? ? 'all@novawulf.io' : 'iamnader@gmail.com'
    mail(to: to_address, subject: @subject)
  end
end

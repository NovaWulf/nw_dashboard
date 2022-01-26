class NotificationMailer < ApplicationMailer
  def notification
    @subject = params[:subject]
    @text = Array(params[:text])
    to_address = Rails.env.production? ? 'novaall@novawulf.io' : 'nader@novawulf.io'
    mail(to: to_address, subject: @subject)
  end
end

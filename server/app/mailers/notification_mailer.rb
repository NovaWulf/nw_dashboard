class NotificationMailer < ApplicationMailer
  def notification
    @subject = params[:subject]
    @text = Array(params[:text])
    mail(to: 'iamnader@gmail.com', subject: @subject)
  end
end

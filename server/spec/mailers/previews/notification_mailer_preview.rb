# frozen_string_literal: true

class NotificationMailerPreview < ActionMailer::Preview
  def notification
    NotificationMailer.with(
      subject: 'MVRV Alert',
      text: 'MVRV just crossed 2.75 with a value of 2.78.'
    ).notification
  end
end

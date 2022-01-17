# frozen_string_literal: true

class ServiceResult
  def initialize
    @value = yield if block_given?
    @error = nil
    @error_message = nil
  rescue ArgumentError => e
    @error = e
    @error_message = e.message
  rescue ActiveRecord::RecordInvalid => e
    @error = e
    @error_message = e.record.errors.full_messages.join(', ')
  rescue StandardError => e
    @error = e
    @error_message = e.message
  ensure
    if @error
      Rails.logger.error(@error_message)
      Rails.logger.error(@error.backtrace)
    end
  end

  def ok?
    @error.blank?
  end

  attr_reader :error, :error_message, :value
end

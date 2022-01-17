# frozen_string_literal: true

class ServiceResult
    def initialize
      @value = yield if block_given?
      @error = nil
      @error_message = nil
    rescue ArgumentError => arg_error
      @error = arg_error
      @error_message = arg_error.message
    rescue ActiveRecord::RecordInvalid => invalid
      @error = invalid
      @error_message = invalid.record.errors.full_messages.join(", ")
    rescue StandardError => se
      @error = se
      @error_message = se.message
    ensure
      if @error
        Rails.logger.error(@error_message)
        Rails.logger.error(@error.backtrace)
        Raven.capture_exception(@error)
      end
    end
  
    def ok?
      @error.blank?
    end
  
    attr_reader :error, :error_message, :value
  end
  
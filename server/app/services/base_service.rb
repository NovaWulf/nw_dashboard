# frozen_string_literal: true

class BaseService
  
    def self.run(*args, &block)
      @instance = nil
      result = ServiceResult.new {
        Rails.logger.info "Calling #{self.class} with arguments(#{args})"
        @instance = new(*args, &block)
        @instance.run
      }
      result
    end
  end
  
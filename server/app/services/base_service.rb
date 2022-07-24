# frozen_string_literal: true

class BaseService
  def self.run(*args, &block)
    @instance = nil
    ServiceResult.new do
      Rails.logger.info "Calling #{name} with arguments(#{args})"
      @instance = new(*args, &block)
      @instance.run
    end
  end
end

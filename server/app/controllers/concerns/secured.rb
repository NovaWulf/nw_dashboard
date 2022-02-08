module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    auth_token
  rescue JWT::VerificationError, JWT::DecodeError => e
    Rails.logger.error(e)
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def http_token
    debugger
    request.headers['Authorization'].split(' ').last if request.headers['Authorization'].present?
  end

  def auth_token
    JsonWebToken.verify(http_token)
  end
end

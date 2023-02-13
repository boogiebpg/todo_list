# frozen_string_literal: true

class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    return if @current_user

    render json: { error: 'Not Authorized' }, status: 401
  end
end

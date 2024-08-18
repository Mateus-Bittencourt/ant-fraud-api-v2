class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [:login]

  def login
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = jwt_encode(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { errors: 'Senha ou email incorretos' }, status: :unauthorized
    end
  end

  private

  def jwt_encode(payload, exp = 1.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end

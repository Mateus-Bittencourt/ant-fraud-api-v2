class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    Rails.logger.info "Token: #{header}"
    decoded = jwt_decode(header)
    Rails.logger.info "Decoded payload: #{decoded.inspect}"
    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      Rails.logger.info "Current user: #{@current_user.inspect}"
      render json: { errors: 'Usuário não encontrado' }, status: :unauthorized unless @current_user
    else
      render json: { errors: 'Você precisa estar logado para acessar este recurso' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'Usuário não encontrado' }, status: :unauthorized
  end

  def jwt_decode(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base)[0].with_indifferent_access
  rescue JWT::DecodeError
    nil
  end
end

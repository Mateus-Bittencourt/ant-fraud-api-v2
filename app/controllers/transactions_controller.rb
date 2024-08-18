class TransactionsController < ApplicationController
  # Endpoint para criar uma nova transação
  def create
    transaction = Transaction.new(transaction_params)
    antifraud_service = AntiFraudService.new(transaction)

    if transaction.save
      # Chamar o job para análise mais detalhada
      FraudAnalysisJob.perform_async(transaction.id)

      # Retornar a recomendação inicial
      recommendation = antifraud_service.call
      render json: recommendation
    else
      render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Endpoint para registrar chargebacks
  def register_chargeback
    transaction_id = params[:transaction_id]
    transaction = Transaction.find_by(transaction_id: transaction_id)

    if transaction
      transaction.update!(has_cbk: true)
      render json: { message: 'Chargeback registrado com sucesso' }, status: :ok
    else
      render json: { error: 'Transação não encontrada' }, status: :not_found
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, :device_id)
  end
end

class TransactionsController < ApplicationController
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

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, :device_id)
  end
end

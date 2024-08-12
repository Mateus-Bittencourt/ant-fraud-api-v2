class TransactionsController < ApplicationController
  def create
    transaction = Transaction.new(transaction_params)
    antifraud_service = AntiFraudService.new(transaction)

    recommendation = antifraud_service.call
    render json: recommendation
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, :device_id)
  end
end

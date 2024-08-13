class FraudAnalysisJob
  include Sidekiq::Job

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    if high_risk?(transaction)
      transaction.update!(suspected_fraud: true)
      add_to_suspicious_entities(transaction)
      report_to_acquirer(transaction)
    end
  end

  private

  def high_risk?(transaction)
    suspicious_user?(transaction) || suspicious_merchants?(transaction) || suspicious_device?(transaction) || excessive_transactions?(transaction)
  end

  def suspicious_user?(transaction)
    SuspiciousUser.exists?(user_id: transaction.user_id)
  end

  def suspicious_device?(transaction)
    SuspiciousDevice.exists?(device_id: transaction.device_id)
  end

  def suspicious_merchants?(transaction)
    SuspiciousMerchant.exists?(merchant_id: transaction.merchant_id)
  end

  def excessive_transactions?(transaction)
    excessive_transactions_with_merchant?(transaction) ||
    excessive_card_numbers?(transaction) ||
    excessive_devices?(transaction)
  end

  def excessive_transactions_with_merchant?(transaction)
    Transaction.where(user_id: transaction.user_id, merchant_id: transaction.merchant_id)
                .where('DATE(transaction_date) = ?', transaction.transaction_date.to_date)
                .count > 5
  end

  def excessive_card_numbers?(transaction)
    Transaction.where(user_id: transaction.user_id)
                .select(:card_number)
                .distinct
                .count > 3
  end

  def excessive_devices?(transaction)
    Transaction.where(user_id: transaction.user_id)
                .select(:device_id)
                .distinct
                .count > 3
  end

  def add_to_suspicious_entities(transaction)
    SuspiciousUser.find_or_create_by(user_id: transaction.user_id) if suspicious_user?(transaction)
    SuspiciousMerchant.find_or_create_by(merchant_id: transaction.merchant_id) if suspicious_merchants?(transaction)
    SuspiciousDevice.find_or_create_by(device_id: transaction.device_id) if suspicious_device?(transaction)
  end

  def report_to_acquirer(transaction)
    # Implementar lógica para enviar informações para a API da adquirente
  end
end

class AntiFraudService
  def initialize(transaction)
    @transaction = transaction
  end

  def call
    @transaction.recommendation = recommendation
    @transaction.save!
    { transaction_id: @transaction.transaction_id, recommendation: @transaction.recommendation }
  end

  private

  def recommendation
    suspicious_transaction? ? 'deny' : 'approve'
  end

  def suspicious_transaction?
    # Example rules:
    too_many_transactions_in_a_row? || high_value_transaction? || user_has_chargeback?
  end

  def too_many_transactions_in_a_row?
    recent_transactions = Transaction.where(user_id: @transaction.user_id)
                                      .where('transaction_date > ?', 5.minutes.ago)
                                      .count
    recent_transactions > 3
  end

  def high_value_transaction?
    limit = Transaction.calculate_limit(@transaction.user_id)
    @transaction.transaction_amount > limit
  end

  def user_has_chargeback?
    Transaction.where(user_id: @transaction.user_id, has_cbk: true).exists?
  end
end

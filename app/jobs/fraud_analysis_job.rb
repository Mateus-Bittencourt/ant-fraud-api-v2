require 'net/http'
require 'uri'
require 'json'

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
    suspicious_user?(transaction) || suspicious_merchant?(transaction) || suspicious_device?(transaction) || excessive_transactions?(transaction)
  end

  def suspicious_user?(transaction)
    SuspiciousUser.exists?(user_id: transaction.user_id)
  end

  def suspicious_device?(transaction)
    SuspiciousDevice.exists?(device_id: transaction.device_id)
  end

  def suspicious_merchant?(transaction)
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
    SuspiciousMerchant.find_or_create_by(merchant_id: transaction.merchant_id) if suspicious_merchant?(transaction)
    SuspiciousDevice.find_or_create_by(device_id: transaction.device_id) if suspicious_device?(transaction)
  end

  def report_to_acquirer(transaction)
    uri = URI.parse("http://localhost:3000/report_fraud")

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = {
      transaction_id: transaction.transaction_id,
      suspected_fraud: transaction.suspected_fraud
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Failed to report transaction #{transaction.transaction_id} to acquirer: #{response.body}")
    end
  end
end

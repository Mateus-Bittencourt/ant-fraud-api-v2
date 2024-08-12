class Transaction < ApplicationRecord
   # Calcular o limite baseado nas transações do mesmo usuário
   def self.calculate_limit(user_id)
    # Buscar transações do mesmo usuário nos últimos 30 dias
    transactions = where(user_id: user_id).where("created_at > ?", 30.days.ago)
    transaction_amounts = transactions.pluck(:transaction_amount)

    # Se o histórico tiver menos de 5 transações, use um limite fixo
    return 1000 if transaction_amounts.size < 5

    # Cálculo baseado em média e desvio padrão
    mean = transaction_amounts.sum / transaction_amounts.size.to_f
    variance = transaction_amounts.sum { |amount| (amount - mean) ** 2 } / transaction_amounts.size.to_f
    std_dev = Math.sqrt(variance)

    # Defina o limite como média + 2 desvios padrão
    mean + 3 * std_dev
  end

  # Verificar se a transação é considerada de alto valor
  def high_value_transaction?
    limit = self.class.calculate_limit(user_id)
    transaction_amount > limit
  end
end

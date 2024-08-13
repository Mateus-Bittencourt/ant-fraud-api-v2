class SuspiciousMerchant < ApplicationRecord
  # Adicione quaisquer validações ou métodos relevantes aqui
  validates :merchant_id, presence: true, uniqueness: true
end

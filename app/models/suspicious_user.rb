class SuspiciousUser < ApplicationRecord
  # Adicione quaisquer validações ou métodos relevantes aqui
  validates :user_id, presence: true, uniqueness: true
end

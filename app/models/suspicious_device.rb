class SuspiciousDevice < ApplicationRecord
  # Adicione quaisquer validações ou métodos relevantes aqui
  validates :device_id, presence: true, uniqueness: true
end

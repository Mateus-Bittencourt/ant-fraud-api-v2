class User < ApplicationRecord
  # Include BCrypt to use has_secure_password
  has_secure_password

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 4 }, if: :password_required?

  private

  def password_required?
    password_digest.blank? || !password.nil?
  end
end

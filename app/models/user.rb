# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :restrict_with_exception
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end

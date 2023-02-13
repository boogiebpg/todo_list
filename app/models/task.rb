# frozen_string_literal: true

class Task < ApplicationRecord
  validates :title, :description, :completed, presence: true
end

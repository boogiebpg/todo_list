# frozen_string_literal: true

class Task < ApplicationRecord
  has_many :subtasks, dependent: :restrict_with_exception
  belongs_to :user
  validates :title, :description, presence: true
end

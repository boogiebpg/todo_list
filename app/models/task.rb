# frozen_string_literal: true

class Task < ApplicationRecord
  has_many :subtasks, dependent: :restrict_with_exception
  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings

  attr_accessor :tags_array

  validates :title, :description, presence: true
end

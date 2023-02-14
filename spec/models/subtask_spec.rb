# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subtask, type: :model do
  describe 'associations' do
    it { should belong_to(:task).optional(false) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end
end

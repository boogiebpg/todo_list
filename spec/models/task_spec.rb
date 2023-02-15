# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should have_many(:subtasks).dependent(:restrict_with_exception) }
    it { should belong_to(:user).optional(false) }
    it { should have_many(:taggings) }
    it { should have_many(:tags).through(:taggings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end
end

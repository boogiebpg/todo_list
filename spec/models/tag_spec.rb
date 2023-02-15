# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it { should have_many(:taggings) }
    it { should have_many(:tasks).through(:taggings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end

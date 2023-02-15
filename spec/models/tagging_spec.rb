require 'rails_helper'

RSpec.describe Tagging, type: :model do
  describe 'associations' do
    it { should belong_to(:tag).optional(false) }
    it { should belong_to(:task).optional(false) }
  end
end

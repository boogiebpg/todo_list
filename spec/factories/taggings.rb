# frozen_string_literal: true

FactoryBot.define do
  factory :tagging do
    task { create(:task) }
    tag { create(:tag) }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "user#{SecureRandom.hex}@email.com" }
    password { Faker::Internet.password }
  end
end

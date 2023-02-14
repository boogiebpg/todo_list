# frozen_string_literal: true

FactoryBot.define do
  factory :subtask do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    completed { false }
    due { Time.current + rand(30).days }
    task { create(:task) }
  end
end

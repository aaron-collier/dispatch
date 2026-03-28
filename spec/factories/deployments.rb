FactoryBot.define do
  factory :deployment do
    association :repository
    environment { :prod }
    sequence(:revision) { |n| "abc#{n.to_s.rjust(4, '0')}" }
    date        { 1.day.ago }
    user        { "amcollie" }

    trait :stage do
      environment { :stage }
    end

    trait :qa do
      environment { :qa }
    end
  end
end

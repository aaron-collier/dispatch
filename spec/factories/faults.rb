FactoryBot.define do
  factory :fault do
    association :repository
    environment    { :prod }
    sequence(:revision) { |n| "abc#{n.to_s.rjust(4, '0')}" }
    date           { 1.day.ago }
    title          { "RuntimeError: something went wrong" }
    sequence(:honeybadger_id) { |n| "hb_fault_#{n}" }

    trait :stage do
      environment { :stage }
    end

    trait :qa do
      environment { :qa }
    end
  end
end

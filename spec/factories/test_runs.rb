FactoryBot.define do
  factory :test_run do
    association :integration_test
    status   { "queuing" }
    duration { nil }
    output   { nil }

    trait :running do
      status { "running" }
    end

    trait :passed do
      status { "passed" }
    end

    trait :failed do
      status { "failed" }
    end
  end
end

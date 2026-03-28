FactoryBot.define do
  factory :integration_test do
    sequence(:name) { |n| "test_feature_#{n}" }
    description { "An integration test." }
  end
end

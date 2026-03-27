FactoryBot.define do
  factory :update_pull_request do
    association :repository
    sequence(:pull_request) { |n| n }
    status { :open }
    build  { :passing }

    trait :failing  do
      build { :failing }
    end

    trait :building do
      build { :building }
    end

    trait :closed do
      status { :closed }
    end

    trait :merged do
      status { :merged }
    end
  end
end

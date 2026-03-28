FactoryBot.define do
  factory :repository do
    sequence(:name) { |n| "sul-dlss/repo-#{n}" }
    last_updated    { Date.current }
    cocina_models_update { false }
    exclude_envs    { nil }
    non_standard_envs { nil }
    skip_audit      { false }
    project_id      { "hbp_abc123" }
  end
end

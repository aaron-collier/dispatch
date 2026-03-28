RubyLLM.configure do |config|
  config.anthropic_api_key = Settings.anthropic_api_key.presence || ENV["ANTHROPIC_API_KEY"]
end

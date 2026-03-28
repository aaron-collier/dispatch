RubyLLM.configure do |config|
  config.openai_api_key = Settings.openai_api_key.presence || ENV["OPENAI_API_KEY"]
end

namespace :integration_tests do
  desc "Seed IntegrationTest records from sul-dlss/infrastructure-integration-test spec/features"
  task seed: :environment do
    repo  = "sul-dlss/infrastructure-integration-test"
    path  = "spec/features"
    token = Settings.github_auth_token.presence || ENV["GH_ACCESS_TOKEN"].presence

    client = Octokit::Client.new(access_token: token)

    puts "Fetching spec file list from #{repo}/#{path}…"
    entries = client.contents(repo, path: path)
    spec_files = entries.select { |e| e.type == "file" && e.name.end_with?("_spec.rb") }
    puts "Found #{spec_files.length} spec files."

    spec_files.each do |entry|
      name = entry.name.delete_suffix("_spec.rb")

      begin
        raw = client.contents(repo, path: entry.path)
        content = Base64.decode64(raw.content)

        puts "  Generating description for #{name}…"
        response = RubyLLM.chat(model: "gpt-4o").ask(
          "In 1-2 sentences, describe what this Ruby integration test file verifies. " \
          "Be specific about what feature or workflow it tests. " \
          "Reply with only the description, no preamble.\n\n#{content}"
        )
        description = response.content.strip

        IntegrationTest.find_or_create_by!(name: name) do |t|
          t.description = description
        end

        puts "  ✓ #{name}"
      rescue StandardError => e
        Rails.logger.error("integration_tests:seed failed for #{name}: #{e.message}")
        puts "  ✗ #{name} — #{e.message}"
      end
    end

    puts "Done. #{IntegrationTest.count} integration tests in database."
  end
end

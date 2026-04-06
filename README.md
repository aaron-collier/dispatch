# Dispatch

Dispatch is a personal devops dashboard for monitoring and managing a group of Rails applications. It tracks open dependency-update pull requests and their CI build status, records deployments and Honeybadger faults by environment, and surfaces the results of the sul-dlss infrastructure integration test suite — all in one place, updated live via Turbo Streams.

## Screenshot

### Dark mode


<img width="1552" height="1180" alt="Screenshot 2026-04-06 at 2 25 22 PM" src="https://github.com/user-attachments/assets/8b4e4dec-1c8e-46e2-8a2b-d7d5c66df581" />

### Light mode


<img width="1546" height="1164" alt="Screenshot 2026-04-06 at 2 25 32 PM" src="https://github.com/user-attachments/assets/b8ec6ef2-72cd-447a-8999-f15f30cbec55" />

---

## Developer Setup

### Prerequisites

- Ruby 3.4.2 (see `.ruby-version`)
- Node.js + Yarn (for CSS compilation)
- SQLite 3

### First-time setup

```bash
bin/setup
```

This installs gems, builds CSS, and prepares the development database.

### Start the development server

```bash
bin/dev
```

Starts Rails and the CSS watcher via Foreman on `http://localhost:3000`.

### Database

Run pending migrations:

```bash
bin/rails db:migrate
```

Seed integration test records from GitHub (requires a GitHub token and OpenAI API key — see [Configuration](#configuration) below):

```bash
rake integration_tests:seed
```

This fetches every `*_spec.rb` file from `sul-dlss/infrastructure-integration-test/spec/features`, uses GPT-4o to generate a one-sentence description for each, and upserts the results into the `integration_tests` table. Safe to re-run; existing records are not overwritten.

### Running tests

```bash
bundle exec rspec          # full suite
bundle exec rspec path/to/spec.rb  # single file
```

### Linting and CI checks

```bash
bin/ci                # full CI pipeline (rubocop, brakeman, bundler-audit, yarn audit, rspec)
bin/rubocop           # Ruby linting
bin/brakeman          # security analysis
```

---

## Configuration

Dispatch uses the [`config`](https://github.com/rubyconfig/config) gem. All settings live in `config/settings.yml` with defaults. Override them locally by creating `config/settings.local.yml` (git-ignored).

### `config/settings.local.yml`

```yaml
# Your Stanford SUNetID — used as your display name and email on the sidebar
sunetid: your-sunetid

# Your full name shown in the sidebar
name: Your Name

# GitHub username for sidebar avatar and profile link
github:
  username: your-github-username

# GitHub personal access token — needs repo read access
# Used by FetchDependencyUpdatesJob and the integration_tests:seed task
github_auth_token: ghp_xxxxxxxxxxxxxxxxxxxx

# OpenAI API key — used by the integration_tests:seed rake task (gpt-4o)
openai_api_key: sk-xxxxxxxxxxxxxxxxxxxx

# Hostname of the SSH control master target (for the Control Master indicator)
control_master_host: your-server-hostname

# Honeybadger API settings (defaults are fine for sul-dlss; adjust if self-hosting)
honeybadger_api:
  url: https://app.honeybadger.io/v2
```

### Environment variable fallbacks

The following settings can be supplied as environment variables instead of (or in addition to) `settings.local.yml`:

| Setting | Environment variable |
|---|---|
| `github_auth_token` | `GH_ACCESS_TOKEN` |
| `openai_api_key` | `OPENAI_API_KEY` |

`settings.local.yml` values take precedence over environment variables when both are present.

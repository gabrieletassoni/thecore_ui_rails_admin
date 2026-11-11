# CLAUDE.md — thecore_ui_rails_admin

Rails engine gem that wires [RailsAdmin](https://github.com/railsadminteam/rails_admin) into a
Thecore host application: Devise + CanCanCan glue, a base controller with shared error handling,
per-model RailsAdmin concerns for the core auth/backend-commons models, custom root/member/collection
actions, i18n locales, and a default `navigation_label`/`navigation_icon` for any model without its
own concern. Public gem on RubyGems; lives as a git submodule inside a parent Thecore application.

## Where things are

```
lib/thecore_ui_rails_admin.rb      entry point; engine.rb is a bare Rails::Engine, no hooks
config/initializers/after_initialize.rb   the wiring hub (controllers, auth, actions, concerns)
config/initializers/concern_*.rb   per-model RailsAdmin concerns + concern_default_navigation.rb
config/initializers/abilities.rb   Abilities::ThecoreUiRailsAdmin
lib/root_actions/  lib/member_actions/  lib/collection_actions/   custom RailsAdmin actions
lib/rails_admin_abstract_controller.rb   RailsAdmin parent controller (rescue_from, locale)
config/locales/{en,it}.thecore_ui_ra.yml   db/migrate (SavedFilter, UserPreference)
test/dummy/                        PostgreSQL-only dummy app
docs/adr/  docs/agents/
```

## Read before working on…

| Topic | File |
| --- | --- |
| Wiring hub, per-model concerns, root/member/collection actions, controller concerns, abilities, migrations, locales, ATOM isolation | `docs/agents/architecture.md` |
| Default navigation label/icon for models with no concern (`DefaultModuleRegistry`, override order) | `docs/agents/default-navigation.md` |
| Dummy app, Postgres test DB, boot stubs, authenticated request tests | `docs/agents/test-infrastructure.md` |
| CodeQL, secret scanning, Dependabot, `config/brakeman.ignore` | `docs/agents/security-scanning.md` |
| Issues (GitHub), triage labels, glossary/ADR layout | `docs/agents/issue-tracker.md`, `triage-labels.md`, `domain.md` |

## Commands

```bash
# One-time: create the Postgres test database (from test/dummy)
(cd test/dummy && RAILS_ENV=test bin/rails db:create)

# Run the whole suite (from inside the submodule directory)
BUNDLE_GEMFILE=Gemfile RAILS_ENV=test bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].each { |f| require File.expand_path(f) }'

# Run one file
BUNDLE_GEMFILE=Gemfile RAILS_ENV=test bundle exec ruby -Itest test/thecore_ui_rails_admin_test.rb

# Bundle install
BUNDLE_GEMFILE=Gemfile bundle install
```

Tests run on PostgreSQL only (never SQLite) and are safe with the devcontainer's `DATABASE_URL`
set — no need to unset it; see `docs/agents/test-infrastructure.md`.

## Rules

- **ATOM isolation**: this gem never assumes a specific model's *domain* logic — it only injects
  RailsAdmin configuration onto models defined elsewhere (host app, `thecore_auth_commons`,
  `thecore_backend_commons`). `model_driven_api` is not a dependency: nothing here may reference it.
- Field-level RailsAdmin configuration lives only in hand-written `ThecoreUiRailsAdmin<Model>Concern`s;
  the default concern only ever sets `navigation_label`/`navigation_icon`, never field-level config.
- Keep `RailsAdmin::Config::Actions.all` called in `after_initialize.rb` before this gem's own action
  files are required, or the base actions (and every `edit_path`/`index_path`) silently disappear.
- Any table touched on a request path in tests — even behind a `rescue` — must exist: a failed
  statement aborts the Postgres transactional-test transaction.
- Secret scanning push protection: if it fires on a real secret, remove it from the commit and
  rotate the secret; never bypass it.
- Publishing happens from `.github/workflows/gempush.yml` on every push to `release/3`, only when
  the version in `lib/*/version.rb` isn't tagged yet: never bump it unless a release is intended.
- Keep this file, or the `docs/agents/` file it points to, accurate whenever the behaviour it
  describes changes.

## Agent skills

### Issue tracker

Tasks, issues, bugs, tickets and specs for this repository live **only** in its GitHub Issues
(`gabrieletassoni/thecore_ui_rails_admin`), handled with the `gh` CLI. See `docs/agents/issue-tracker.md`.

**Mandatory rule.** Whenever a skill or development work creates, reads, updates, comments on,
assigns, blocks or closes a task, issue, bug, ticket or spec (for example /to-tickets, /to-spec,
/triage, /wayfinder, /implement, /diagnosing-bugs, /code-review, closing a piece of work, a bug found
during a session), do it in this repository's GitHub Issues following `docs/agents/issue-tracker.md`.
Never use Odoo, `.scratch/` or local Markdown files as a tracker: Odoo is only for the repositories
on Bancolini's GitLab. `#123` means a GitHub issue number of this repository. If `gh` doesn't work,
stop and say so instead of falling back to another tracker.

### Triage labels

The five canonical triage roles map to GitHub labels with the same name (`needs-triage`,
`needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root, created lazily when the first
term or decision is resolved. See `docs/agents/domain.md`.

### Skills

Matt Pocock's skills come from the `mattpocock-skills` Claude Code plugin installed on the
developer's **host** (`claude plugins install mattpocock-skills`, official marketplace), never
vendored here: no `.agents/skills/`, `.claude/commands/` or `skills-lock.json`. Its `ask-matt` skill
maps how the skills connect.

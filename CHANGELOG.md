# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] - 2026-09-21

First public release — extracted from the private `scripts` monorepo to a
standalone open-source repo. No git history carried over (clean break);
fresh `config/master.key` + `credentials.yml.enc` generated for this repo.

### Migrated — Rails 2.2.2 → Rails 8.1, Ruby 1.8 → Ruby 3.4.10

The entire application was migrated from Rails 2.2.2 (2008) to Rails 8.1
with Ruby 3.4.10 via rbenv before the extraction.

### Added

- `Gemfile` and `Gemfile.lock` (Bundler) — replaces Rails 2 `config.gem`
  declarations. Includes `gruff`, `rmagick`, `csv`, `puma`, `propshaft`,
  `turbo-rails`, `stimulus-rails`, `importmap-rails`.
- `.ruby-version` pinning Ruby 3.4.10 via rbenv.
- Modern Rails 8 config: `config/application.rb`, `config/boot.rb`,
  `config/environment.rb`, `config/environments/*`, `config/initializers/*`,
  `config/puma.rb`, `config/importmap.rb`.
- `config/credentials.yml.enc` for encrypted credentials (the
  `master.key` is gitignored, standard Rails practice).
- `bin/` executables (`rails`, `rake`, `setup`, `dev`, `brakeman`,
  `bundler-audit`, `ci`, `importmap`).
- `app/assets/stylesheets/application.css` with Propshaft asset pipeline.
- `app/javascript/` with Importmap, Turbo, and Stimulus.
- `.github/dependabot.yml` with cooldown periods (7-day default).
- `.github/workflows/ci.yml` with SHA-pinned GitHub Actions: Brakeman,
  bundler-audit, importmap audit, and a Semgrep CE scan.
- `.semgrep.yml` with custom Ruby rules (ReDoS, eval, command injection)
  — CE-only local rules, run with `--oss-only`.
- `README.md` with CI, CodeFactor, and DeepWiki badges.
- `AGENTS.md` with project overview, tech stack, architecture, and
  development instructions for AI coding agents.
- Borg Collective brand icon as local assets:
  - `public/icon.svg` — full SVG brand icon from borg-collective.eu.
  - `public/icon.png` — 96x96 PNG favicon.
  - `public/apple-touch-icon.png` — 180x180 PNG for Apple devices.
  - `public/navbar-icon.png` — 180x180 PNG for navbar display.
  - `public/watermark.svg` — SVG with white/light backgrounds removed,
    leaving only the red Borg Collective logo for watermark use.
- Borg Collective icon displayed in the navbar (top-left) next to the
  application name.
- Centered watermark on the page using the cleaned SVG at 5% opacity,
  scaling with viewport width (`40vw`, min 200px, max 600px).
- Favicon and apple-touch-icon links in the layout `<head>`.
- Bulma 1.0.2 CSS framework committed locally as
  `app/assets/stylesheets/bulma.min.css`.

### Changed

- `SteadyStatesController` ported to Rails 8 conventions: modern parameter
  handling (`params[:name].present?`), string interpolation, symbol-to-string
  key changes.
- `BpController` → `BpsController` (renamed to match `resources :bps`
  routing convention). `FasterCSV` replaced with stdlib `CSV`.
- Routes migrated from Rails 2 `map.resources` / `map.connect` syntax to
  modern `resources` DSL with `collection` blocks.
- Views updated: `form_tag`/`form_for` → `form_with` where appropriate,
  route helpers updated (`steady_states_path`, `graph_bps_path`).
- Layout updated to Rails 8 template with `csrf_meta_tags`, `csp_meta_tag`,
  `stylesheet_link_tag :app`, `javascript_importmap_tags`, and modern
  viewport meta tags.
- Flash message fade animation moved from Prototype.js `Effect.Fade` to
  CSS `@keyframes` in `application.css`.
- CSRF protection: explicit `protect_from_forgery with: :exception` in
  `ApplicationController`.
- `allow_browser versions: :modern` added to `ApplicationController`.
- `application.html.erb` restored to clean Rails 8 layout (debug code
  removed); form inputs, tables, boxes, and notifications made transparent
  so the watermark shows through all content.

### Removed

- All Rails 2 config files (`config/boot.rb`, `config/environment.rb`,
  `config/environments/*`, `config/initializers/*`, `config/database.yml`,
  `config/routes.rb` — all regenerated for Rails 8).
- `script/` directory (Rails 2 scripts — replaced by `bin/`).
- `nbproject/` (NetBeans project files).
- `test/` directory (Rails 2 test scaffolding — placeholder tests only).
- `doc/`, `log/`, `Rakefile` (regenerated for Rails 8).
- `public/dispatch.*`, `public/404.html`, `public/422.html`,
  `public/500.html`, `public/favicon.ico`, `public/robots.txt`,
  `public/images/rails.png` (replaced by Rails 8 defaults).
- `lib/graph.rb` (standalone debug script, not used by the app).
- Vendored JavaScript libraries: Prototype.js 1.6.0.3, Scriptaculous
  `controls.js`, `dragdrop.js`, `effects.js` (replaced by CSS animation).
- `FasterCSV` dependency (replaced by Ruby stdlib `CSV`).
- `config.gem` declarations (replaced by Bundler `Gemfile`).
- Default catch-all routes (`map.connect ':controller/:action/:id'`).
- `.semgrepignore` (no longer needed — vendored files removed).
- `dopamin.png` — generated graph artifact at repo root, unreferenced.
- `app/javascript/controllers/hello_controller.js` — Stimulus boilerplate;
  no `data-controller` attribute exists in any view.
- `app/views/pwa/` — manifest + service worker scaffold never wired into
  the layout.

### Fixed

- **Critical: `ArgumentError (wrong number of arguments (given 2, expected 1))`
  on session-bearing requests.** Root cause: the `json` gem 3.0.2 changed
  `JSON.parse` to accept only one argument. ActiveSupport 8.1.3.1 calls
  `JSON.parse` with two arguments when decrypting session cookies, causing
  every request with a session cookie to fail with a 500 error. Pinned
  `gem "json", "~> 2.0"` in the Gemfile (resolves to 2.21.2). The error
  surfaced through `csrf_meta_tags` only because the template rendered
  after session decryption failed.
- Removed temporary debug `rescue_from ArgumentError` from
  `ApplicationController`, `config/initializers/csp_debug.rb`, and a
  `begin/rescue` debug block around `csp_meta_tag` in the layout.

### Security

- CSRF protection hardened with explicit `protect_from_forgery with:
  :exception`.
- HTML entity escaping for JSON output enabled (XSS prevention).
- Default catch-all routes removed (prevents unintended action exposure).
- GitHub Actions pinned to commit SHAs (supply chain protection).
- Dependabot cooldown periods configured (7-day minimum).
- Semgrep CI is CE-only: repo-local `.semgrep.yml` rules with
  `--oss-only --metrics off` — no registry packs, no cloud upload.

### Verification

- `bundle exec rails runner` confirms Rails 8.1.3.1 on Ruby 3.4.10.
- `rails server` boots successfully; all routes return 200 OK
  (`/`, `/steady_states`, `/bps`), with and without session cookies.
- Icon assets served correctly: `/icon.svg`, `/icon.png`,
  `/apple-touch-icon.png`, `/navbar-icon.png`, `/watermark.svg`.
- `json` gem confirmed at 2.21.2 (downgraded from 3.0.2).

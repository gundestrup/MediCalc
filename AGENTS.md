# AGENTS.md — MediCalc

> **Single source of truth for all coding agents working on this project.**

## Project overview

MediCalc is a medical calculation tool with two features:

1. **Steady State Calculator** — calculates drug steady-state concentration
   over time from dosage, half-life, and administration count. Generates a
   Gruff line graph as a PNG response.
2. **Blood Pressure Calculator** — uploads a CSV file and generates a blood
   pressure graph via Gruff.

The app has no persistent domain model (no ActiveRecord tables in use).
All computation is request-scoped.

## Tech stack

| Component | Technology | Version |
| --- | --- | --- |
| Language | Ruby (rbenv) | 3.4.10 |
| Framework | Rails | 8.1.3.1 |
| Web server | Puma | 8.0.2 |
| Asset pipeline | Propshaft | — |
| JS | Importmap, Turbo Rails, Stimulus Rails | — |
| CSS | Bulma (committed locally) | 1.0.2 |
| Graphing | Gruff (depends on rmagick) | 0.32.0 |
| Image lib | rmagick | 7.1.4 |
| CSV | Ruby stdlib `csv` gem | — |
| Security | Brakeman, Bundler Audit, Importmap audit | CI |

## Architecture

### Controllers

- `ApplicationController` — CSRF protection (`protect_from_forgery with:
  :exception`), `allow_browser versions: :modern`,
  `stale_when_importmap_changes`.
- `SteadyStatesController#index` — renders the form; if params are present,
  computes steady-state concentration and sends a PNG graph via
  `send_data(g.to_blob, ...)`.
- `BpsController#index` — renders the upload form.
- `BpsController#graph` — parses uploaded CSV, generates a Gruff graph,
  sends PNG via `send_data`.

### Routes (`config/routes.rb`)

```ruby
root "steady_states#index"
resources :steady_states
resources :bps do
  collection { get :graph; post :graph }
end
get "up" => "rails/health#show"
```

### Views

- `layouts/application.html.erb` — Rails 8 layout with `csrf_meta_tags`,
  `csp_meta_tag`, Bulma navbar, Borg Collective navbar icon, centered
  watermark, flash messages, Importmap tags.
- `steady_states/index.html.erb` — Steady State form (Bulma styled).
- `bps/index.html.erb` — Blood Pressure CSV upload form (Bulma styled).

### Assets

- `app/assets/stylesheets/bulma.min.css` — Bulma 1.0.2 (committed, not CDN).
- `app/assets/stylesheets/application.css` — custom styles: watermark,
  navbar icon, transparent backgrounds for form/table/box/notification.
- Propshaft serves files in alphabetical order; `application.css` loads
  before `bulma.min.css`, so `!important` is used for overrides.

### Public assets (Borg Collective branding)

| File | Purpose |
| --- | --- |
| `public/icon.svg` | Full brand icon SVG (with white background) |
| `public/icon.png` | 96x96 PNG favicon |
| `public/apple-touch-icon.png` | 180x180 Apple touch icon |
| `public/navbar-icon.png` | 180x180 PNG for navbar display |
| `public/watermark.svg` | Brand icon with white/light fills removed |

## Known constraints

1. **`json` gem pinned to `~> 2.0`.** The `json` gem 3.0 changed
   `JSON.parse` to accept only one argument, breaking ActiveSupport
   session cookie decryption (which passes two arguments). Do not upgrade
   `json` to 3.x without verifying ActiveSupport compatibility.

2. **`gruff` requires `rmagick`.** Do not replace `rmagick` with
   `ruby-vips` without also replacing `gruff` — `gruff` 0.32.0 explicitly
   depends on `rmagick`.

3. **Bulma load order.** Propshaft serves `application.css` before
   `bulma.min.css` (alphabetical). Use `!important` for Bulma overrides
   in `application.css`.

4. **No database at all.** The `active_record` railtie is not loaded and
   there is no `config/database.yml` — all computation is request-scoped.

## Development

```bash
rbenv use 3.4.10
bundle install
bin/rails server    # http://127.0.0.1:3000
```

### Verification

```bash
# Boot check
bundle exec rails runner "puts Rails.version"

# Security scans
bundle exec brakeman
bundle exec bundle-audit check
bin/importmap audit

# Route checks (with session cookie)
curl -s -c /tmp/cookies.txt -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/
curl -s -b /tmp/cookies.txt -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/steady_states
curl -s -b /tmp/cookies.txt -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/bps
```

All routes must return 200 with and without session cookies.

## CI

- `.github/workflows/ci.yml` — Brakeman + Bundler Audit + Importmap audit
  (SHA-pinned actions). `bin/ci` (`config/ci.rb`) runs the same checks locally.
- `.github/dependabot.yml` — Dependabot with 7-day cooldown.

## Definition of done

1. Root cause fixed (not patched), with file:line traceability.
2. All routes return 200 OK with and without session cookies.
3. No new Brakeman or Bundler Audit warnings.
4. `CHANGELOG.md` updated for material changes.
5. `README.md` updated if user-facing behavior or setup changes.

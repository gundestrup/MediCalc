# MediCalc

[![CI](https://github.com/gundestrup/MediCalc/actions/workflows/ci.yml/badge.svg)](https://github.com/gundestrup/MediCalc/actions/workflows/ci.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/gundestrup/medicalc/badge)](https://www.codefactor.io/repository/github/gundestrup/medicalc)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/gundestrup/MediCalc)
[![License](https://img.shields.io/github/license/gundestrup/MediCalc)](LICENSE)

A medical calculation tool for drug steady-state concentrations and blood
pressure graphing. Built with Ruby on Rails 8.1 on Ruby 3.4.10.

## Features

- **Steady State Calculator** — calculates drug steady-state concentration
  over time based on dosage, half-life, and number of administrations.
  Generates a concentration-time graph using Gruff.
- **Blood Pressure Calculator** — uploads a CSV file and generates a blood
  pressure graph.
- **Borg Collective branding** — navbar icon, centered watermark, and
  favicon from [borg-collective.eu](https://www.borg-collective.eu/).

## Tech stack

| Component | Technology |
| --- | --- |
| Language | Ruby 3.4.10 (rbenv) |
| Framework | Rails 8.1.3.1 |
| Web server | Puma 8.0.2 |
| Asset pipeline | Propshaft |
| JavaScript | Importmap, Turbo Rails, Stimulus Rails |
| CSS framework | Bulma 1.0.2 (committed locally) |
| Graphing | Gruff (with rmagick) |
| CSV parsing | Ruby stdlib CSV |
| Database | None — `active_record` is not loaded; computation is request-scoped |
| Security scanning | Brakeman, Bundler Audit, Importmap audit (CI) |

## Getting started

```bash
# Ensure Ruby 3.4.10 is active
rbenv use 3.4.10

# Install dependencies
bundle install

# Start the development server
bin/rails server
```

The app is available at `http://127.0.0.1:3000`.

## Routes

| Path | Description |
| --- | --- |
| `/` | Steady State Calculator (root) |
| `/steady_states` | Steady State Calculator |
| `/bps` | Blood Pressure Calculator |
| `/bps/graph` | BP graph generation (POST) |
| `/up` | Health check |

## Security

- CSRF protection enabled (`protect_from_forgery with: :exception`).
- `csp_meta_tag` and `csrf_meta_tags` in the layout.
- `allow_browser versions: :modern` restricts to modern browsers.
- Brakeman, Bundler Audit, and Importmap audit run in CI (`.github/workflows/ci.yml`).
- Dependabot configured with 7-day cooldown periods.
- GitHub Actions pinned to commit SHAs.

## Project structure

```text
MediCalc/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── steady_states_controller.rb
│   │   └── bps_controller.rb
│   ├── views/
│   │   ├── layouts/application.html.erb
│   │   ├── steady_states/index.html.erb
│   │   └── bps/index.html.erb
│   ├── assets/stylesheets/
│   │   ├── application.css      # custom styles (watermark, transparency)
│   │   └── bulma.min.css        # Bulma 1.0.2 framework
│   └── javascript/              # Importmap, Turbo, Stimulus
├── config/
│   ├── application.rb
│   ├── routes.rb
│   └── initializers/
├── public/
│   ├── icon.svg                 # Borg Collective brand icon (full)
│   ├── icon.png                 # 96x96 favicon
│   ├── apple-touch-icon.png     # 180x180 Apple touch icon
│   ├── navbar-icon.png          # 180x180 navbar icon
│   └── watermark.svg            # Brand icon with backgrounds removed
├── .github/
│   ├── workflows/ci.yml         # Brakeman + Bundler Audit
│   └── dependabot.yml
├── Gemfile
├── CHANGELOG.md
├── AGENTS.md
└── README.md
```

## Known constraints

- The `json` gem is pinned to `~> 2.0` because `json` 3.0 changed
  `JSON.parse` to accept only one argument, which breaks ActiveSupport
  session cookie decryption. See `CHANGELOG.md` for details.
- `gruff` depends on `rmagick`; both are required for graph generation.
  Do not replace `rmagick` with `ruby-vips` without replacing `gruff` first.
- Bulma is loaded before `application.css` (alphabetical order via
  Propshaft), so custom overrides use `!important` where needed.

## License

This project is licensed under the AGPL-3.0-or-later License — see the
[LICENSE](LICENSE) file for details.

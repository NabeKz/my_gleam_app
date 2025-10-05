# Repository Guidelines

## Project Structure & Module Organization
Source lives in `src/`. `src/bank_app.gleam` defines the public entry, `src/app/` hosts the web surface, `src/features/` captures domain flows, and `src/shared/` stores cross-cutting helpers. Tests reside in `test/` and follow one file per feature. Database assets sit in `db/` (`schema.sql`, `sql/`, `atlas.hcl`), while generated build artifacts land in `build/`. Project configuration is tracked in `gleam.toml`, `manifest.toml`, and environment tooling in `mise.toml`.

## Build, Test, and Development Commands
Run `gleam run` to execute the application locally. Use `gleam test` for the full Gleam test suite, and `gleam format` before committing to normalize code style. `gleam check --warnings-as-errors` keeps the codebase warning-free ahead of CI. Start a live-reloading dev loop with `mise run serve`. Manage Atlas migrations via `mise run db:migrate`, reset with `mise run db:reset`, and inspect the live schema through `mise run db:output` or `mise run db:debug` for an interactive SQLite shell.

## Coding Style & Naming Conventions
Rely on `gleam format` to enforce the canonical 4-space indentation and line wrapping. Keep module filenames snake_case, public functions lower_snake_case, and type names in UpperCamelCase. Organise features by directory and expose constructors through small public APIs. Prefer `///` doc comments for public modules and `//` inline notes for implementation details.

## Testing Guidelines
Tests use `gleeunit`, located under `test/`. Name suites `<feature>_test.gleam` and mirror the module being exercised. Write assertions for both success and failure paths, especially around database IO. Run `gleam test` before every push; if migrations change, include fixtures or adapters so the suite stays deterministic. When adding integration helpers, guard them behind reusable fixtures in `test/`.

## Commit & Pull Request Guidelines
Follow the `type: summary` pattern seen in history (`feat:`, `refactor:`, `fix:`). Keep subjects imperative and under 72 characters. Each pull request should outline the change, note schema or config updates, and link tracking issues. Include screenshots or `curl` transcripts when adjusting HTTP surfaces, and call out any new tasks that should be added to `mise`. Ensure the branch is rebased and tests pass prior to requesting review.

## Database & Configuration Tips
Atlas drives migrations; confirm `atlas.hcl` stays in sync with `schema.sql`. Generated SQLite files should not be committed—add them to `.gitignore` when working locally. When switching environments, set required tool versions via `mise install` to keep Erlang/Gleam parity with CI.

## MUST
Reply in Japanese.
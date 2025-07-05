# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running the application
- `mise run serve` - Start the development server with file watching (uses watchexec)
- `gleam run` - Run the application once
- The app runs on port 8000

### Database operations
- `mise run migrate` - Reset and recreate the SQLite database with Atlas migrations

### Testing
- `gleam test` - Run all tests

### Build
- `gleam build` - Build the project

## Architecture

This is a Gleam web application implementing a helpdesk/ticket management system using Clean Architecture principles.

### Core Structure
- **Domain Layer**: Pure business logic in `src/app/features/*/domain.gleam`
- **Use Case Layer**: Application logic in `src/app/features/*/usecase/` and `*_usecase.gleam`
- **Adapter Layer**: External interfaces in `src/app/adaptor/`
- **Infrastructure**: Data persistence in `src/app/features/*/infra/`

### Web Framework
- Uses **Wisp** as the web framework with **Mist** as the HTTP server
- Routes split into API (`api_router.gleam`) and web pages (`web_router.gleam`)
- Web pages return HTML strings, API endpoints handle JSON
- HTTP method override support for forms (DELETE via form POST)

### Data Storage
The app supports multiple storage backends through dependency injection in `context.gleam`:
- **ETS** (default): In-memory Erlang Term Storage
- **Memory**: Simple in-memory lists
- **SQLite**: Persistent database (partially implemented)

### Key Domain Entities
- **Ticket**: Support tickets with status management (Open/Closed/Done)
- **User**: Simple user management
- **Reply**: Ticket responses/comments

### Request Flow
1. `app.gleam` - Entry point, starts HTTP server
2. `router.gleam` - Routes to API or web handlers
3. Controllers/Pages - Handle specific routes
4. Use cases - Business logic
5. Repositories - Data persistence

### Testing Strategy
- Unit tests for domain logic validation
- Integration tests for use cases
- Test fixtures in `test/ticket/fixture.gleam`
- Uses **gleeunit** testing framework

### Notable Patterns
- Dependency injection through Context
- Repository pattern for data access
- Form validation using custom validator module
- Cookie-based authentication (partially implemented)
- Clean separation between web pages and API endpoints
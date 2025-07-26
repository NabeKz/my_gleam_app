# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Gleam web application for library management with book lending functionality. The application follows domain-driven design principles and uses the Wisp web framework with Mist as the HTTP server.

## Development Commands

### Core Commands
- `gleam run` - Start the web server on port 8000
- `gleam test` - Run all tests using gleeunit
- `gleam build` - Build the project
- `gleam format` - Format source code
- `gleam check` - Type check the project

### Development Tasks
- `mise run serve` - Start development server with auto-reload using watchexec
- `mise run start` - Start server in background for testing (no logs)
- `mise run stop` - Stop background server
- `mise install` - Install development tools (Erlang, Gleam, Rebar)

### Package Management
- `gleam add <package>` - Add a dependency
- `gleam deps download` - Download dependencies
- `gleam deps list` - List dependencies

## Architecture

### Functional Core, Imperative Shell
The application follows the **Functional Core, Imperative Shell** architecture pattern with domain-driven design principles:

```
src/
├── core/                     # Pure functions only (no side effects)
│   ├── shared/              # Common domain (lowest layer)
│   │   ├── types/           # Shared value objects
│   │   └── services/        # Shared domain services
│   ├── book/                # Book bounded context
│   │   ├── types/           # Book entities and value objects
│   │   ├── services/        # Book domain services
│   │   └── ports/           # Book repository interfaces
│   └── loan/                # Loan bounded context
│       ├── types/           # Loan entities and value objects
│       ├── services/        # Loan domain services (can depend on book)
│       └── ports/           # Loan repository interfaces
├── shell/                   # Side effects handling
│   ├── shared/              # Common infrastructure
│   └── adapters/            # External system connections
│       ├── web/             # HTTP handlers and routing
│       └── persistence/     # Database repositories
└── app/                     # Application composition
    ├── context.gleam        # Dependency injection setup
    └── web.gleam           # Application entry point
```

### Dependency Rules
The architecture enforces strict dependency rules to prevent circular dependencies:

**Layer Dependencies:**
```
shared ← types ← services ← ports
```

**Detailed Rules:**
1. **shared/** (lowest layer)
   - Dependencies: None
   - Can be referenced by: All layers

2. **types/**
   - Dependencies: `shared/` only
   - Same layer: Cannot reference other domains' types (must go through `shared/types`)

3. **services/**
   - Dependencies: `shared/` + own domain/other domains' `types/`
   - Same layer: Cannot reference other domains' services (must go through `shared/services`)

4. **ports/**
   - Dependencies: `shared/` + own domain/other domains' `types/` + own domain's `services/`
   - Same layer: Cannot reference other domains' ports

**Cross-Domain Dependencies:**
- `loan` domain can depend on `book` domain (loan creation requires book validation)
- `book` domain cannot depend on `loan` domain
- All cross-domain logic requiring both domains should go in `shared/services/`

### Context Pattern
The application uses dependency injection through the context pattern (`app/context.gleam`). The Context type contains function references for all external dependencies, making testing easier by allowing function substitution.

### Domain Features
- **Book Management** - Search books with title/author filtering
- **Loan Management** - Create loans with 14-day due dates, retrieve loan information

### API Endpoints
- `GET /api/books` - Search books with optional query parameters
- `POST /api/books` - Create new book
- `GET /api/loans` - List all loans
- `GET /api/loans/:id` - Get specific loan
- `POST /api/loans` - Create new loan
- `GET /api/health_check` - Health check endpoint

### Dependencies
- `wisp` - Web framework for HTTP handling
- `mist` - HTTP server
- `gleam_json` - JSON encoding/decoding
- `gleam_http` - HTTP types and utilities
- `gleam_erlang` - Erlang interop
- `gleam_otp` - OTP utilities
- `gluid` - UUID generation
- `gleeunit` - Testing framework (dev dependency)

### Testing Framework
Uses gleeunit for testing. Test functions must end with `_test` suffix. Integration tests use `wisp/testing` for HTTP testing with context substitution for mocking dependencies.

## Development Environment

Uses `mise` for tool management with Erlang, Gleam, and Rebar. The development server supports auto-reload via watchexec when source files change.

## Testing Procedures

### Background Server Testing
For API testing and integration tests, use the background server tasks:

```bash
# 1. Start server in background (no logs)
mise run start

# 2. Wait for server startup (2-3 seconds)
sleep 3

# 3. Run tests
curl -X POST http://localhost:8000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Book", "author": "Test Author"}'

# 4. Stop server
mise run stop
```

**Testing Checklist:**
- ✅ Successful cases (201 Created)
- ✅ Validation errors (400 Bad Request) 
- ✅ Data persistence (GET to verify)
- ✅ Japanese UTF-8 support

**Note:** `mise run stop` may show task error but server stops correctly. Verify with health check if needed.
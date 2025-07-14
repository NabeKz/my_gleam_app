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
- `mise install` - Install development tools (Erlang, Gleam, Rebar)

### Package Management
- `gleam add <package>` - Add a dependency
- `gleam deps download` - Download dependencies
- `gleam deps list` - List dependencies

## Architecture

### High-Level Structure
The application follows a clean architecture with domain-driven design:

- **Domain Layer** (`features/*/domain.gleam`, `features/*/loan.gleam`) - Core business logic with opaque types
- **Port Layer** (`features/*/port/`) - Interface definitions and domain identifiers
- **Repository Layer** (`features/*/*_repo_on_ets.gleam`) - Data persistence using ETS
- **Service Layer** (`features/*/service.gleam`) - Application services and use cases
- **Handler Layer** (`app/handler/`) - HTTP request handlers
- **Router Layer** (`app/router.gleam`) - HTTP routing and middleware
- **Shared Layer** (`shared/`) - Common utilities and cross-cutting concerns

### Context Pattern
The application uses a context pattern for dependency injection (`shared/context.gleam`). The Context type contains function references for all external dependencies, making testing easier by allowing function substitution.

### Domain Features
- **Book Management** - Search books with title/author filtering
- **Loan Management** - Create loans with 14-day due dates, retrieve loan information

### API Endpoints
- `GET /api/books` - Search books with optional query parameters
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
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Gleam library project named `library_app` - a basic library template with minimal functionality. The project follows standard Gleam conventions and uses the Gleam package manager.

## Development Commands

### Core Commands
- `gleam run` - Execute the main application
- `gleam test` - Run all tests using gleeunit
- `gleam build` - Build the project
- `gleam format` - Format source code
- `gleam check` - Type check the project

### Package Management
- `gleam add <package>` - Add a dependency
- `gleam deps download` - Download dependencies
- `gleam deps list` - List dependencies

## Architecture

### Project Structure
- `src/library_app.gleam` - Main module with entry point
- `test/library_app_test.gleam` - Test module using gleeunit
- `gleam.toml` - Project configuration and dependencies
- `manifest.toml` - Lock file for dependencies

### Dependencies
- `gleam_stdlib` - Standard library (>= 0.44.0 and < 2.0.0)
- `gleeunit` - Testing framework (dev dependency)

### Testing Framework
The project uses gleeunit for testing. Test functions must end with `_test` suffix and use the `should` module for assertions.

## Development Environment

The project uses `mise` for tool management with:
- Erlang (latest)
- Gleam (latest) 
- Rebar (latest)

Run `mise install` to set up the development environment.
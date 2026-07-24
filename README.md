# Licensor

An [MCP (Model Context Protocol)](https://modelcontextprotocol.io/) server for discovering, downloading, and writing open-source software licenses. Built on Rails and deployed at `https://license.theglasshaus.org/v1/mcp`.

## Intent & Scope

The goal of Licensor is to give AI agents and human developers a **canonical, authoritative source** for open-source license text. Rather than generating license text from training data (which risks drift, omissions, or paraphrasing), Licensor fetches exact text from [GitHub's license API](https://docs.github.com/en/rest/licenses) and exposes it through a standardized MCP interface.

### What it does

- **Discover** — List all licenses available on GitHub with metadata (key, name, SPDX ID)
- **Recommend** — Suggest a license based on project philosophy (permissive, copyleft, public domain, etc.)
- **Fetch** — Retrieve the exact canonical text for any license
- **Write** — Save a license file to disk with optional template variable substitution
- **Guide** — Provide structured MCP prompts for common licensing workflows

### What it does not do

- Provide legal advice (it is not a law firm)
- Modify or interpret license terms
- Enforce license compliance
- Host its own license text (always fetches from GitHub's upstream API)

## Usage

### MCP Endpoint

The server is available over MCP Streamable HTTP transport at:

```
https://license.theglasshaus.org/v1/mcp
```

### Available Tools

| Tool | Description |
|------|-------------|
| `list_licenses` | List all available open-source licenses with metadata from GitHub's license API |
| `get_license` | Fetch the full text of a specific license (e.g., `mit`, `apache-2.0`, `cc0-1.0`) |
| `recommend_license` | Get a license recommendation based on your requirements (permissive, copyleft, patent grant, etc.) |
| `write_license` | Fetch a license and write it to a file, with optional template variable substitution (`[year]`, `[fullname]`, `[project]`, `[description]`) |

### Example: Adding a License

1. **List available licenses**
   ```json
   { "jsonrpc": "2.0", "method": "tools/call", "params": { "name": "list_licenses" } }
   ```

2. **Fetch the text**
   ```json
   { "jsonrpc": "2.0", "method": "tools/call", "params": { "name": "get_license", "arguments": { "license_key": "mit" } } }
   ```

3. **Write it to disk**
   ```json
   { "jsonrpc": "2.0", "method": "tools/call", "params": { "name": "write_license", "arguments": { "license_key": "mit", "year": "2026", "fullname": "Jane Doe" } } }
   ```

### Available Prompts

| Prompt | Description |
|--------|-------------|
| `add_license` | Step-by-step workflow for adding a license to a project |
| `choose_license` | Guidance for selecting the right license based on goals and use case |
| `license_workflow` | End-to-end workflow for add, replace, compare, or verify actions |

Prompts are retrieved via `prompts/get` and provide structured guidance that agents can use as context before invoking tools.

## Running Locally

### Requirements

- Ruby 4.0+
- Rails 8+
- Bundler

### Setup

```bash
bundle install
```

### Tests

```bash
bundle exec rspec
```

### Start the Server

```bash
bin/rails server
```

The MCP endpoint will be available at `http://localhost:3000/v1/mcp`.

## API Documentation

Interactive Swagger UI is available at the root path `/` when running locally, documenting all MCP protocol endpoints (initialize, tools/list, tools/call, prompts/list, prompts/get).

## License

This project itself is licensed under [CC0 1.0 Universal](LICENSE) — dedicated to the public domain.

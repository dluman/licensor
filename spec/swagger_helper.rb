# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag' command it asks which document to generate
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Licensor MCP API",
        version: "v1",
        description: "Model Context Protocol (MCP) server for discovering, downloading, and writing open source software licenses.\n\nThis API exposes a single JSON-RPC endpoint (`/v1/mcp`) over the MCP Streamable HTTP transport. Clients initialize a session, then call tools such as `list_licenses`, `get_license`, `recommend_license`, and `write_license`.\n\nLearn more about MCP at https://modelcontextprotocol.io/"
      },
      servers: [
        {
          url: "http://localhost:3000/v1",
          description: "Local development server"
        }
      ],
      paths: {}
    }
  }

  # Specify the format of the output Swagger file (json or yaml)
  config.openapi_format = :yaml
end

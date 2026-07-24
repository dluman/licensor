# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Mcp
  module Tools
    class ListLicenses < MCP::Tool
      tool_name "list_licenses"
      description "List all available open source licenses with metadata from GitHub's license API"
      input_schema(
        properties: {},
        required: [],
      )
      output_schema(
        properties: {
          licenses: {
            type: "array",
            items: {
              type: "object",
              properties: {
                key: { type: "string" },
                name: { type: "string" },
                spdx_id: { type: "string" },
              },
            },
          },
        },
        required: ["licenses"],
      )

      class << self
        def call(server_context:)
          uri = URI("https://api.github.com/licenses")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Get.new(uri)
          request["Accept"] = "application/vnd.github.v3+json"
          request["User-Agent"] = "licensor-mcp-server/1.0"

          response = http.request(request)

          unless response.is_a?(Net::HTTPSuccess)
            return MCP::Tool::Response.new(
              [{ type: "text", text: "Error fetching licenses: #{response.code} #{response.message}" }],
              error: true,
            )
          end

          licenses = JSON.parse(response.body)
          formatted = licenses.map do |license|
            {
              key: license["key"],
              name: license["name"],
              spdx_id: license["spdx_id"],
            }
          end

          MCP::Tool::Response.new(
            [{ type: "text", text: formatted.to_json }],
            structured_content: { licenses: formatted },
          )
        rescue StandardError => e
          MCP::Tool::Response.new(
            [{ type: "text", text: "Error: #{e.message}" }],
            error: true,
          )
        end
      end
    end
  end
end

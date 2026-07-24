# frozen_string_literal: true

module Tools
  module DigitalOcean
    class ListDroplets < MCP::Tool
      extend Base

      tool_name "list_droplets"
      description "List all DigitalOcean droplets (virtual machines) in your account"
      input_schema(
        properties: {},
        required: [],
      )
      output_schema(
        properties: {
          droplets: {
            type: "array",
            items: {
              type: "object",
              properties: {
                id: { type: "integer" },
                name: { type: "string" },
                status: { type: "string" },
                region: { type: "string" },
                size: { type: "string" },
                image: { type: "string" },
                ip_address: { type: "string" },
                created_at: { type: "string" }
              }
            }
          }
        },
        required: [ "droplets" ],
      )

      class << self
        def call(server_context:)
          response = do_get("/droplets")
          data = parse_response(response)

          if data[:error]
            return error_response("DigitalOcean API error: #{data[:status]} #{data[:message]}\n#{data[:body]}")
          end

          droplets = (data["droplets"] || []).map do |d|
            {
              id: d["id"],
              name: d["name"],
              status: d["status"],
              region: d.dig("region", "slug"),
              size: d.dig("size", "slug"),
              image: d.dig("image", "slug"),
              ip_address: d.dig("networks", "v4")&.find { |n| n["type"] == "public" }&.dig("ip_address"),
              created_at: d["created_at"]
            }
          end

          MCP::Tool::Response.new(
            [ { type: "text", text: "Found #{droplets.length} droplet(s)" } ],
            structured_content: { droplets: droplets },
          )
        rescue StandardError => e
          error_response("Error: #{e.message}")
        end
      end
    end
  end
end

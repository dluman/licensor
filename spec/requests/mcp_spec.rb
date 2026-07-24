# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "MCP License Server", type: :request do
  # ---------------------------------------------------------------------------
  # POST /mcp - initialize
  # ---------------------------------------------------------------------------
  path "/mcp" do
    post "Initialize MCP session" do
      tags [ "MCP Protocol" ]
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          jsonrpc: { type: :string, example: "2.0" },
          id: { type: :integer, example: 1 },
          method: { type: :string, example: "initialize" },
          params: {
            type: :object,
            properties: {
              protocolVersion: { type: :string, example: "2024-11-05" },
              capabilities: { type: :object },
              clientInfo: {
                type: :object,
                properties: {
                  name: { type: :string, example: "licensor-client" },
                  version: { type: :string, example: "1.0.0" }
                }
              }
            }
          }
        }
      }

      response "200", "Initialized" do
        let(:body) do
          {
            jsonrpc: "2.0",
            id: 1,
            method: "initialize",
            params: {
              protocolVersion: "2024-11-05",
              capabilities: {},
              clientInfo: { name: "licensor-client", version: "1.0.0" }
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["jsonrpc"]).to eq("2.0")
          expect(data["result"]["serverInfo"]["name"]).to eq("licensor")
          expect(response.headers["mcp-session-id"]).to be_present
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /mcp - tools/list
  # ---------------------------------------------------------------------------
  path "/mcp" do
    post "List available tools" do
      tags [ "MCP Tools" ]
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          jsonrpc: { type: :string, example: "2.0" },
          id: { type: :integer, example: 2 },
          method: { type: :string, example: "tools/list" },
          params: { type: :object }
        }
      }

      response "200", "Tools listed" do
        let(:body) do
          {
            jsonrpc: "2.0",
            id: 2,
            method: "tools/list",
            params: {}
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["result"]["tools"]).to be_an(Array)
          expect(data["result"]["tools"].map { |t| t["name"] }).to include("list_licenses", "get_license", "recommend_license", "write_license")
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /mcp - tools/call (get_license)
  # ---------------------------------------------------------------------------
  path "/mcp" do
    post "Call a tool (get_license example)" do
      tags [ "MCP Tools" ]
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          jsonrpc: { type: :string, example: "2.0" },
          id: { type: :integer, example: 3 },
          method: { type: :string, example: "tools/call" },
          params: {
            type: :object,
            properties: {
              name: { type: :string, example: "get_license" },
              arguments: {
                type: :object,
                properties: {
                  license_key: { type: :string, example: "mit" },
                  year: { type: :string, example: "2026" },
                  fullname: { type: :string, example: "Jane Doe" }
                }
              }
            }
          }
        }
      }

      response "200", "Tool result returned" do
        let(:body) do
          {
            jsonrpc: "2.0",
            id: 3,
            method: "tools/call",
            params: {
              name: "get_license",
              arguments: { license_key: "mit", year: "2026", fullname: "Jane Doe" }
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["result"]["content"]).to be_an(Array)
          expect(data["result"]["content"].first["text"]).to include("MIT License")
        end
      end
    end
  end
end

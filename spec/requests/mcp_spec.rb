# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "MCP License Server", type: :request do
  path "/mcp" do
    post "MCP JSON-RPC endpoint" do
      tags "MCP"
      consumes "application/json"
      produces "application/json", "text/event-stream"
      operationId "mcp_rpc"
      description <<~DESC
        Single JSON-RPC endpoint for the Model Context Protocol (MCP)
        Streamable HTTP transport. Send JSON-RPC requests for initialize,
        tools/list, tools/call, prompts/list, and prompts/get.
      DESC

      parameter name: :body,
                in: :body,
                required: true,
                description: "JSON-RPC request body",
                schema: {
                  oneOf: [
                    {
                      type: :object,
                      title: "initialize",
                      properties: {
                        jsonrpc: { type: :string, example: "2.0" },
                        id: { type: :integer, example: 1 },
                        method: { type: :string, enum: [ "initialize" ] },
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
                    },
                    {
                      type: :object,
                      title: "tools/list",
                      properties: {
                        jsonrpc: { type: :string, example: "2.0" },
                        id: { type: :integer, example: 2 },
                        method: { type: :string, enum: [ "tools/list" ] },
                        params: { type: :object }
                      }
                    },
                    {
                      type: :object,
                      title: "tools/call",
                      properties: {
                        jsonrpc: { type: :string, example: "2.0" },
                        id: { type: :integer, example: 3 },
                        method: { type: :string, enum: [ "tools/call" ] },
                        params: {
                          type: :object,
                          properties: {
                            name: { type: :string, enum: [ "get_license" ] },
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
                    },
                    {
                      type: :object,
                      title: "prompts/list",
                      properties: {
                        jsonrpc: { type: :string, example: "2.0" },
                        id: { type: :integer, example: 4 },
                        method: { type: :string, enum: [ "prompts/list" ] },
                        params: { type: :object }
                      }
                    },
                    {
                      type: :object,
                      title: "prompts/get",
                      properties: {
                        jsonrpc: { type: :string, example: "2.0" },
                        id: { type: :integer, example: 5 },
                        method: { type: :string, enum: [ "prompts/get" ] },
                        params: {
                          type: :object,
                          properties: {
                            name: { type: :string, enum: [ "add_license" ] },
                            arguments: {
                              type: :object,
                              properties: {
                                license_key: { type: :string, example: "mit" }
                              }
                            }
                          }
                        }
                      }
                    }
                  ]
                }

      request_body_example(
        value: {
          jsonrpc: "2.0",
          id: 1,
          method: "initialize",
          params: {
            protocolVersion: "2024-11-05",
            capabilities: {},
            clientInfo: { name: "licensor-client", version: "1.0.0" }
          }
        },
        summary: "Initialize MCP session",
        name: "initialize"
      )

      request_body_example(
        value: {
          jsonrpc: "2.0",
          id: 2,
          method: "tools/list",
          params: {}
        },
        summary: "List available tools",
        name: "tools_list"
      )

      request_body_example(
        value: {
          jsonrpc: "2.0",
          id: 3,
          method: "tools/call",
          params: {
            name: "get_license",
            arguments: { license_key: "mit", year: "2026", fullname: "Jane Doe" }
          }
        },
        summary: "Call a tool (get_license)",
        name: "tools_call_get_license"
      )

      request_body_example(
        value: {
          jsonrpc: "2.0",
          id: 4,
          method: "prompts/list",
          params: {}
        },
        summary: "List available prompts",
        name: "prompts_list"
      )

      request_body_example(
        value: {
          jsonrpc: "2.0",
          id: 5,
          method: "prompts/get",
          params: {
            name: "add_license",
            arguments: { license_key: "mit" }
          }
        },
        summary: "Get a prompt (add_license)",
        name: "prompts_get_add_license"
      )

      response "200", "JSON-RPC result" do
        let(:'Accept') { 'application/json, text/event-stream' }
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
          expect(response.headers["mcp-session-id"]).to be_nil
        end
      end

      response "200", "JSON-RPC result" do
        let(:'Accept') { 'application/json, text/event-stream' }
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

      response "200", "JSON-RPC result" do
        let(:'Accept') { 'application/json, text/event-stream' }
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

      response "200", "JSON-RPC result" do
        let(:'Accept') { 'application/json, text/event-stream' }
        let(:body) do
          {
            jsonrpc: "2.0",
            id: 4,
            method: "prompts/list",
            params: {}
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["result"]["prompts"]).to be_an(Array)
          expect(data["result"]["prompts"].map { |p| p["name"] }).to include("add_license", "choose_license", "license_workflow")
        end
      end

      response "200", "JSON-RPC result" do
        let(:'Accept') { 'application/json, text/event-stream' }
        let(:body) do
          {
            jsonrpc: "2.0",
            id: 5,
            method: "prompts/get",
            params: {
              name: "add_license",
              arguments: { license_key: "mit" }
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["result"]["messages"]).to be_an(Array)
          expect(data["result"]["messages"].first["content"]["text"]).to include("Adding an Open Source License")
          expect(data["result"]["messages"].first["content"]["text"]).to include("mit")
        end
      end
    end
  end
end

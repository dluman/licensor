# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "fileutils"

module Mcp
  module Tools
    class WriteLicense < MCP::Tool
      tool_name "write_license"
      description "Fetch a license and write it to a file on the server filesystem. Use this when the client requests a LICENSE file to be created."
      input_schema(
        properties: {
          license_key: {
            type: "string",
            description: "The license key (e.g., mit, apache-2.0, gpl-3.0)",
          },
          path: {
            type: "string",
            description: "The file path to write the license to. Defaults to 'LICENSE' in the current directory.",
          },
          year: {
            type: "string",
            description: "Year to substitute for [year] in the license text (optional)",
          },
          fullname: {
            type: "string",
            description: "Full name to substitute for [fullname] in the license text (optional)",
          },
          project: {
            type: "string",
            description: "Project name to substitute for [project] in the license text (optional)",
          },
          description: {
            type: "string",
            description: "Project description to substitute for [description] in the license text (optional)",
          },
        },
        required: ["license_key"],
      )
      output_schema(
        properties: {
          success: { type: "boolean" },
          path: { type: "string" },
          license: { type: "string" },
          message: { type: "string" },
        },
        required: ["success", "path"],
      )

      class << self
        def call(
          license_key:,
          path: "LICENSE",
          year: nil,
          fullname: nil,
          project: nil,
          description: nil,
          server_context:
        )
          uri = URI("https://api.github.com/licenses/#{license_key}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Get.new(uri)
          request["Accept"] = "application/vnd.github.v3+json"
          request["User-Agent"] = "licensor-mcp-server/1.0"

          response = http.request(request)

          unless response.is_a?(Net::HTTPSuccess)
            return MCP::Tool::Response.new(
              [{ type: "text", text: "Error fetching license '#{license_key}': #{response.code} #{response.message}" }],
              error: true,
            )
          end

          data = JSON.parse(response.body)
          body = data["body"] || ""

          # Substitute template variables
          body = body.gsub("[year]", year.to_s) if year
          body = body.gsub("[fullname]", fullname.to_s) if fullname
          body = body.gsub("[project]", project.to_s) if project
          body = body.gsub("[description]", description.to_s) if description

          # Write to file
          FileUtils.mkdir_p(File.dirname(File.expand_path(path)))
          File.write(File.expand_path(path), body)

          result = {
            success: true,
            path: File.expand_path(path),
            license: data["name"],
            message: "Successfully wrote #{data['name']} to #{path}",
          }

          MCP::Tool::Response.new(
            [{ type: "text", text: result[:message] }],
            structured_content: result,
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

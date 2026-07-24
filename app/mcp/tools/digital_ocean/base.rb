# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Tools
  module DigitalOcean
    module Base
      API_BASE = "https://api.digitalocean.com/v2"

      def api_token
        token = ENV["DIGITALOCEAN_TOKEN"]
        unless token
          raise ArgumentError, "DIGITALOCEAN_TOKEN environment variable is not set"
        end
        token
      end

      def do_get(path)
        uri = URI("#{API_BASE}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{api_token}"
        request["Content-Type"] = "application/json"
        http.request(request)
      end

      def do_post(path, body)
        uri = URI("#{API_BASE}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{api_token}"
        request["Content-Type"] = "application/json"
        request.body = body.to_json
        http.request(request)
      end

      def do_delete(path)
        uri = URI("#{API_BASE}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Delete.new(uri)
        request["Authorization"] = "Bearer #{api_token}"
        http.request(request)
      end

      def parse_response(response)
        unless response.is_a?(Net::HTTPSuccess)
          return { error: true, status: response.code, message: response.message, body: response.body }
        end
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        { error: true, message: "Invalid JSON response: #{e.message}", body: response.body }
      end

      def error_response(message)
        MCP::Tool::Response.new(
          [ { type: "text", text: message } ],
          error: true,
        )
      end
    end
  end
end

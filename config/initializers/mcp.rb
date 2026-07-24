# frozen_string_literal: true

require "mcp"

# Load all tool and prompt definitions
# In development, Zeitwerk autoloads them. In production, we eager load.
Dir[Rails.root.join("app/mcp/tools/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("app/mcp/prompts/**/*.rb")].each { |f| require f }

# Create the MCP server with all license tools and prompts
server = MCP::Server.new(
  name: "licensor",
  version: "1.0.0",
  title: "Licensor MCP Server",
  instructions: "This MCP server provides tools to discover, download, and write common open source software licenses. Use list_licenses to see what's available, recommend_license to get suggestions based on your philosophy, get_license to retrieve text, and write_license to save a license file to disk. Also provides prompts for common licensing workflows.",
  tools: [
    Tools::ListLicenses,
    Tools::GetLicense,
    Tools::RecommendLicense,
    Tools::WriteLicense
  ],
  prompts: [
    Prompts::AddLicense,
    Prompts::ChooseLicense,
    Prompts::LicenseWorkflow
  ],
)

# Create the Streamable HTTP transport
transport = MCP::Server::Transports::StreamableHTTPTransport.new(server)

# Create a Rack app wrapper so we can mount it in Rails routes
class McpRackApp
  def initialize(transport)
    @transport = transport
  end

  def call(env)
    request = Rack::Request.new(env)
    @transport.handle_request(request)
  end
end

# Store the app in a global constant for the router to mount
MCP_LICENSE_APP = McpRackApp.new(transport)

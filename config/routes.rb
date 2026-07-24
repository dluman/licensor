Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/"
  mount Rswag::Api::Engine => "/api-docs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount the MCP Streamable HTTP transport at /v1/mcp
  mount MCP_LICENSE_APP => "/v1/mcp"
end

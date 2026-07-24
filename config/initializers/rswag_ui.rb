Rswag::Ui.configure do |c|
  # Point the Swagger UI at the generated OpenAPI spec served by Rswag::Api
  c.swagger_endpoint "/api-docs/v1/swagger.yaml", "Licensor MCP API V1"

  # Add Basic Auth in case your API is private
  # c.basic_auth_enabled = true
  # c.basic_auth_credentials 'username', 'password'
end

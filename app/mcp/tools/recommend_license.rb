# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Tools
  class RecommendLicense < MCP::Tool
      tool_name "recommend_license"
      description "Recommend an open source license based on your project's requirements and philosophy."
      input_schema(
        properties: {
          permissive: {
            type: "boolean",
            description: "Whether you want a permissive license (allows proprietary use, e.g. MIT, Apache-2.0, BSD). Defaults to true."
          },
          copyleft: {
            type: "boolean",
            description: "Whether you want a copyleft license (requires sharing changes, e.g. GPL, AGPL, LGPL). Defaults to false."
          },
          patent_use: {
            type: "boolean",
            description: "Whether you want explicit patent grant (e.g. Apache-2.0). Defaults to false."
          },
          simple: {
            type: "boolean",
            description: "Whether you prefer a short, simple license (e.g. MIT, BSD-2-Clause). Defaults to true."
          },
          public_domain: {
            type: "boolean",
            description: "Whether you want to dedicate your work to the public domain (e.g. CC0-1.0, Unlicense). Defaults to false."
          },
          network_copyleft: {
            type: "boolean",
            description: "Whether you want network copyleft (SaaS/remote interaction triggers sharing, e.g. AGPL-3.0). Defaults to false."
          }
        },
        required: [],
      )
      output_schema(
        properties: {
          recommendation: { type: "string" },
          license_key: { type: "string" },
          name: { type: "string" },
          reason: { type: "string" }
        },
        required: [ "recommendation", "license_key", "reason" ],
      )

      class << self
        def call(
          permissive: true,
          copyleft: false,
          patent_use: false,
          simple: true,
          public_domain: false,
          network_copyleft: false,
          server_context:
        )
          if public_domain
            return respond("cc0-1.0", "CC0-1.0 dedicates your work to the public domain with a fallback license. Best for data, documentation, or when you want no restrictions at all.")
          end

          if network_copyleft
            return respond("agpl-3.0", "AGPL-3.0 is the strongest copyleft license. It requires sharing source code even for network/SaaS use. Choose this if you want all users of your service to receive the source code.")
          end

          if copyleft
            if simple
              return respond("gpl-3.0", "GPL-3.0 is a strong copyleft license that requires sharing changes when distributing the software. It is well-understood and widely used.")
            else
              return respond("lgpl-2.1", "LGPL-2.1 is a weaker copyleft license. It allows linking with proprietary software while requiring sharing changes to the library itself. Good for libraries.")
            end
          end

          if patent_use
            return respond("apache-2.0", "Apache-2.0 is a permissive license with an explicit patent grant. It protects contributors and users from patent litigation while allowing proprietary use.")
          end

          if simple
            return respond("mit", "MIT License is short, simple, and permissive. It lets people do almost anything with your project. It is the most popular open source license and is used by Ruby on Rails, Babel, and .NET.")
          end

          respond("bsd-3-clause", "BSD-3-Clause is a permissive license with a non-endorsement clause. It prevents use of your name to endorse derivatives without permission.")
        end

        private

        def respond(license_key, reason)
          names = {
            "mit" => "MIT License",
            "apache-2.0" => "Apache License 2.0",
            "gpl-3.0" => "GNU General Public License v3.0",
            "agpl-3.0" => "GNU Affero General Public License v3.0",
            "lgpl-2.1" => "GNU Lesser General Public License v2.1",
            "bsd-2-clause" => "BSD 2-Clause Simplified License",
            "bsd-3-clause" => "BSD 3-Clause New or Revised License",
            "cc0-1.0" => "Creative Commons Zero v1.0 Universal",
            "unlicense" => "The Unlicense",
            "mpl-2.0" => "Mozilla Public License 2.0"
          }

          result = {
            recommendation: names[license_key] || license_key,
            license_key: license_key,
            name: names[license_key] || license_key,
            reason: reason
          }

          MCP::Tool::Response.new(
            [ { type: "text", text: "Recommended: #{result[:recommendation]} (#{license_key})\n\n#{reason}" } ],
            structured_content: result,
          )
        end
      end
  end
end

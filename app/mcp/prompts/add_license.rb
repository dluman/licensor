# frozen_string_literal: true

module Prompts
  class AddLicense < MCP::Prompt
    prompt_name "add_license"
    title "Add an Open Source License"
    description "Step-by-step workflow for adding an open source license to a project. Use this when the user wants to add, write, generate, or create a LICENSE file."
    arguments [
      MCP::Prompt::Argument.new(
        name: "license_key",
        title: "License Key",
        description: "The SPDX license key (e.g., mit, apache-2.0, gpl-3.0, cc0-1.0). Leave blank if unsure."
      ),
      MCP::Prompt::Argument.new(
        name: "project_name",
        title: "Project Name",
        description: "The name of the project (optional, for license template substitution)"
      )
    ]

    class << self
      def template(args, server_context: nil)
        license_key = args["license_key"]
        project_name = args["project_name"]

        steps = []

        if license_key.nil? || license_key.empty?
          steps << "1. **Discover available licenses**: Use `list_licenses` to see all options."
          steps << "2. **Get a recommendation**: If unsure, use `recommend_license` with your project's philosophy (permissive, copyleft, etc.)."
        else
          steps << "1. **Fetch the license text**: Use `get_license` with license_key='#{license_key}'."
        end

        steps << "3. **Write the LICENSE file**: Use `write_license` to save the canonical text to disk."

        if project_name
          steps << "   - Substitute project name: '#{project_name}'"
        end

        steps << "4. **Verify**: Confirm the file was written correctly."

        body = <<~MD
          # Adding an Open Source License

          Follow this workflow to add a license to your project using the Licensor MCP tools:

          #{steps.join("\n")}

          ## Key Principles

          - **Always use the Licensor tools** for license operations to get canonical, legally accurate text.
          - **Never generate license text from memory** — always fetch from the authoritative source.
          - **Substitute template variables** (year, fullname, project, description) when supported by the license.

          ## Common License Keys

          - `mit` — MIT License (permissive, simple)
          - `apache-2.0` — Apache License 2.0 (permissive, patent grant)
          - `gpl-3.0` — GNU GPL v3.0 (strong copyleft)
          - `cc0-1.0` — Creative Commons Zero (public domain dedication)
          - `bsd-3-clause` — BSD 3-Clause (permissive)
        MD

        MCP::Prompt::Result.new(
          description: "Workflow for adding an open source license to a project",
          messages: [
            MCP::Prompt::Message.new(
              role: "user",
              content: MCP::Content::Text.new(body)
            )
          ]
        )
      end
    end
  end
end

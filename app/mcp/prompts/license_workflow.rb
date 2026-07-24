# frozen_string_literal: true

module Prompts
  class LicenseWorkflow < MCP::Prompt
    prompt_name "license_workflow"
    title "Complete Licensing Workflow"
    description "End-to-end workflow for managing open source licenses in a project. Use this when the user needs comprehensive guidance on licensing."
    arguments [
      MCP::Prompt::Argument.new(
        name: "action",
        title: "Action",
        description: "The licensing action: add, replace, compare, or verify"
      ),
      MCP::Prompt::Argument.new(
        name: "license_key",
        title: "License Key",
        description: "SPDX license key (e.g., mit, apache-2.0). Optional for compare/verify actions."
      )
    ]

    class << self
      def template(args, server_context: nil)
        action = args["action"] || "add"
        license_key = args["license_key"]

        case action
        when "add"
          add_workflow(license_key)
        when "replace"
          replace_workflow(license_key)
        when "compare"
          compare_workflow
        when "verify"
          verify_workflow
        else
          generic_workflow(action, license_key)
        end
      end

      private

      def add_workflow(license_key)
        steps = []

        if license_key
          steps << "1. **Preview the license**: `get_license` with license_key='#{license_key}'"
          steps << "2. **Write to project**: `write_license` with license_key='#{license_key}' and any template substitutions (year, fullname, project)"
        else
          steps << "1. **List options**: `list_licenses` to see all available licenses"
          steps << "2. **Get recommendation**: `recommend_license` with your project's requirements"
          steps << "3. **Preview**: `get_license` with the recommended key"
          steps << "4. **Write**: `write_license` with the chosen key"
        end

        steps << "5. **Verify**: Check that `LICENSE` exists and contains the correct text"

        body = build_body("Adding a License", steps)
        build_result(body)
      end

      def replace_workflow(license_key)
        steps = [
          "1. **Identify current license**: Check the existing `LICENSE` file",
          "2. **Compare licenses**: Use `get_license` for both old and new keys to compare terms",
          "3. **Update file**: `write_license` with the new license_key='#{license_key}'",
          "4. **Update headers**: Replace license headers in source files if necessary",
          "5. **Notify contributors**: Changing a license may require agreement from all contributors"
        ]

        body = build_body("Replacing a License", steps)
        build_result(body)
      end

      def compare_workflow
        steps = [
          "1. **Fetch license texts**: Use `get_license` for each license you want to compare",
          "2. **Analyze differences**: Focus on key terms:",
          "   - Permissive vs copyleft",
          "   - Patent grant clauses",
          "   - Attribution requirements",
          "   - Warranty disclaimers",
          "3. **Consider compatibility**: Some licenses are incompatible with each other"
        ]

        body = build_body("Comparing Licenses", steps)
        build_result(body)
      end

      def verify_workflow
        steps = [
          "1. **Read current LICENSE**: Check the file in your project root",
          "2. **Fetch canonical text**: `get_license` with the matching license key",
          "3. **Compare**: Ensure the project file matches the canonical version",
          "4. **Check substitutions**: Verify template variables (year, fullname) are filled in correctly"
        ]

        body = build_body("Verifying a License", steps)
        build_result(body)
      end

      def generic_workflow(action, license_key)
        steps = [
          "1. **List available licenses**: `list_licenses`",
          "2. **Get a recommendation**: `recommend_license` if unsure",
          "3. **Fetch license text**: `get_license` with your chosen key",
          "4. **Write to disk**: `write_license` to save the file"
        ]

        body = build_body("License Workflow (#{action})", steps)
        build_result(body)
      end

      def build_body(title, steps)
        <<~MD
          # #{title}

          #{steps.join("\n")}

          ## Best Practices

          - Always fetch canonical license text from the authoritative source via the Licensor MCP tools
          - Include a `LICENSE` file in the root of every open source project
          - Add a license header to source files for clarity
          - Keep the license text unmodified (except for template substitutions)
          - Choose a license early in the project lifecycle
        MD
      end

      def build_result(body)
        MCP::Prompt::Result.new(
          description: "Complete workflow for managing open source licenses",
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

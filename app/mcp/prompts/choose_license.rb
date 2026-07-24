# frozen_string_literal: true

module Prompts
  class ChooseLicense < MCP::Prompt
    prompt_name "choose_license"
    title "Choose the Right Open Source License"
    description "Guidance for selecting an open source license based on project goals, philosophy, and use case. Use this when the user is unsure which license to pick."
    arguments [
      MCP::Prompt::Argument.new(
        name: "project_type",
        title: "Project Type",
        description: "Type of project: library, application, data, documentation, or other"
      ),
      MCP::Prompt::Argument.new(
        name: "commercial_use",
        title: "Allow Commercial Use",
        description: "Whether you want to allow commercial/proprietary use (true/false)"
      )
    ]

    class << self
      def template(args, server_context: nil)
        project_type = args["project_type"]
        commercial_use = args["commercial_use"]

        body = <<~MD
          # Choosing an Open Source License

          Use `recommend_license` with the following criteria to get a tailored suggestion:

          ## Decision Framework

          | Goal | Recommended License | Key |
          |------|---------------------|-----|
          | Maximum freedom, no attribution | CC0-1.0 | `cc0-1.0` |
          | Simple, permissive, widely used | MIT License | `mit` |
          | Permissive + patent protection | Apache-2.0 | `apache-2.0` |
          | Strong copyleft (share changes) | GPL-3.0 | `gpl-3.0` |
          | Network copyleft (SaaS) | AGPL-3.0 | `agpl-3.0` |
          | Weak copyleft (libraries) | LGPL-2.1 | `lgpl-2.1` |
          | Permissive, no endorsement clause | BSD-3-Clause | `bsd-3-clause` |

          ## For Your Context

        MD

        if project_type
          body += <<~MD
            **Project type**: #{project_type}

          MD
        end

        if commercial_use == "false" || commercial_use == false
          body += <<~MD
            **Commercial use**: NOT allowed → Consider a **copyleft** license (GPL-3.0, AGPL-3.0, LGPL-2.1) to ensure derivatives remain open source.

          MD
        elsif commercial_use == "true" || commercial_use == true
          body += <<~MD
            **Commercial use**: Allowed → Consider a **permissive** license (MIT, Apache-2.0, BSD-3-Clause) for maximum adoption.

          MD
        end

        body += <<~MD
          ## Next Steps

          1. Run `recommend_license` with your preferences.
          2. Review the recommendation and reasoning.
          3. Run `get_license` to preview the text.
          4. Run `write_license` to save it to your project.

          Always use the Licensor tools to get canonical, legally accurate license text.
        MD

        MCP::Prompt::Result.new(
          description: "Guidance for selecting the right open source license",
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

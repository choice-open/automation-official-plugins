import type { ToolDefinition } from "@choiceopen/automation-plugin-sdk-js/types"
import { t } from "../i18n/i18n-node"

export const testingTool = {
  type: "tool",
  name: "testing-tool",
  display_name: t("TESTING_TOOL_DISPLAY_NAME"),
  description: t("TESTING_TOOL_DESCRIPTION"),
  icon: "🧰",
  parameters: [
    {
      name: "location",
      type: "string",
      required: true,
      display_name: t("LOCATION_DISPLAY_NAME"),
      ui: {
        component: "input",
        hint: t("LOCATION_HINT"),
        placeholder: t("LOCATION_PLACEHOLDER"),
        support_expression: true,
        width: "full",
      }
    },
    {
      name: "api_key",
      type: "credential_id",
      credential_name: "testing-api-key",
      required: true,
      display_name: t("API_KEY_DISPLAY_NAME"),
      ui: {
        component: "credential-select",
        hint: t("API_KEY_HINT"),
        placeholder: t("API_KEY_PLACEHOLDER"),
        sensitive: true,
        width: "full",
      }
    }
  ],
  async invoke(..._args) {
    
  },
} satisfies ToolDefinition
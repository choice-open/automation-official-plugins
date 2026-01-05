import { createPlugin } from "@choiceopen/automation-plugin-sdk-js"
import { t } from "./i18n/i18n-node"
import { locales } from "./i18n/i18n-util"
import { loadAllLocalesAsync } from "./i18n/i18n-util.async"
import { testingTool } from "./tools/testing"

await loadAllLocalesAsync()

const plugin = createPlugin({ 
  name: "testing-plugin",
  display_name: t("PLUGIN_DISPLAY_NAME"),
  description: t("PLUGIN_DESCRIPTION"),
  icon: new URL("https://www.google.com/favicon.ico"),
  locales,
  transporterOptions: {
  }
 })

plugin.addTool(testingTool)

plugin.run()

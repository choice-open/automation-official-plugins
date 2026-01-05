import type { Credential } from "@choiceopen/automation-plugin-sdk-js/types";
import { t } from "../i18n/i18n-node";

export const credentialDefinition = {
  name: "testing-api-key",
  display_name: t("CREDENTIAL_DISPLAY_NAME"),
  description: t("CREDENTIAL_DESCRIPTION"),
} satisfies Credential

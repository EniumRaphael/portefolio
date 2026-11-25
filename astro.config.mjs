import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

// SITE_URL peut venir d'un fichier .env (Node >= 20.12) ou de l'environnement (CI, hébergeur)
try {
  process.loadEnvFile();
} catch {
  // pas de fichier .env : on utilise l'environnement ou la valeur par défaut
}
const site = process.env.SITE_URL || "https://example.com";

// https://astro.build/config
export default defineConfig({
  site,
  devToolbar: { enabled: false },
  integrations: [tailwind()],
});

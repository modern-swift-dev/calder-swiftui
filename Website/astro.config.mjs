import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://modern-swift-dev.github.io/docs/calder-swiftui/",
  base: "/docs/calder-swiftui",
  integrations: [],
  vite: {
    plugins: [tailwindcss()]
  }
});

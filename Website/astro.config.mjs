import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://modern-swift-dev.github.io/calder-swiftui/",
  base: "/calder-swiftui",
  integrations: [],
  vite: {
    plugins: [tailwindcss()]
  }
});

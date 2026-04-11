import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://authenticnerd.com",
  build: {
    inlineStylesheets: "never",
  },
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    shikiConfig: {
      theme: "rose-pine",
      wrap: true,
    },
  },
  redirects: {
    '/posts/nifeilz-l6': '/posts/nifeliz-l6',
    '/posts/nifeilz-l6-photos': '/posts/nifeliz-l6-photos',
  }
});

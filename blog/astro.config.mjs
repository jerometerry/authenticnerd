import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: "https://authenticnerd.com",
  build: {
    inlineStylesheets: 'always'
  },
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    shikiConfig: {
      theme: 'rose-pine',
      wrap: true,
    },
  },
});
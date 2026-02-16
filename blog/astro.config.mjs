import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

import preact from "@astrojs/preact";

import tailwindcss from '@tailwindcss/vite';

import mdx from '@astrojs/mdx';

export default defineConfig({
  site: "https://authenticnerd.com",

  build: {
    inlineStylesheets: 'always'
  },

  integrations: [sitemap(), preact(
    {
      compat: true,
    }
  ), mdx()],

  vite: {
    plugins: [tailwindcss()],
  },

  markdown: {
    shikiConfig: {
      theme: 'github-dark',
      wrap: true,
    },
  },
});
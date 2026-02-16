import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

import preact from "@astrojs/preact";

export default defineConfig({
  site: "https://authenticnerd.com",
  build: {
    inlineStylesheets: 'always'
  },
  integrations: [sitemap(), preact(
    {
      compat: true,
    }
  )],
});
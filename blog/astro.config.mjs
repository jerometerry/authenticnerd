import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

import preact from "@astrojs/preact";

export default defineConfig({
  site: "https://authenticnerd.com",
  integrations: [sitemap(), preact(
    {
      compat: true,
    }
  )],
});
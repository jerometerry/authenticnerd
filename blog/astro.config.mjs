import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

import preact from "@astrojs/preact";

export default defineConfig({
  integrations: [sitemap(), preact(
    {
      compat: true,
    }
  )],
});
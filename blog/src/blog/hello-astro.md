---
title: 'Hello, Astro!'
pubDate: 2026-02-16
description: "Kicking the tires on Astro for this blog"
author: 'Jerome Terry'
image:
    url: 'astro-logo-dark.png'
    alt: 'Dark Astro brand logo, on light background'
tags: ["astro", "software engineering", "software development", "blogging"]
---

## Blogging. About my own blog?!?

Well this is weird. I'm writing about my blog inside my blog. How, ... meta? 

My blog, [authenticnerd.com](https://authenticnerd.com/), is a static content website built using 
[Astro](https://astro.build/). Static assests are stored in S3, and are served up from CloudFront. AWS infrastructure 
is managed with Terraform. The source for this blog is on 
[GitHub](https://github.com/jerometerry/authenticnerd), if you are so inclined.

### The Blogging Process

To create this post, I created a new markdown file, hello-astro.md in the `/src/blog` directory. 

I downloaded an official [Astro brand logo](https://astro.build/press/#assets) and added it to the project in the  
`/src/assets/` directory. Astro cleverly intercepted right click on their logo on the 
[astro.build](https://astro.build/) website.

### Frontmatter

Astro markdown files start with a YAML code block, known as frontmatter, wrapped in tripple dashes, like so:

```yaml
---
title: 'Hello, Astro!'
pubDate: 2026-02-16
description: "Kicking the tires on Astro for this blog"
author: 'Jerome Terry'
image:
    url: 'astro-logo-dark.png'
    alt: 'Dark Astro brand logo, on light background'
tags: ["astro", "software engineering", "software development", "blogging"]
---
```

The schema I chose for the frontmatter looks identical to the frontmatter that's in the 
[Build your first Astro blog](https://docs.astro.build/en/tutorial/0-introduction/) tutorial. We all start somewhere.

### Content

The content of the markdown file is the same as the GitHub markdown format. I felt right at home!

To make things weirder, here's a copy / paste of the introduction section at the top of this file, so you see what I 
mean.

```markdown
### Blogging. About my own blog?!?

Well this is weird. I'm writing about my blog inside my blog. How, ... meta? 

My blog, [authenticnerd.com](https://authenticnerd.com/), is a static content website built using 
[Astro](https://astro.build/). Static assests are stored in S3, and are served up from CloudFront. AWS infrastructure 
is managed with Terraform. The source for this blog is on 
[GitHub](https://github.com/jerometerry/authenticnerd), if you are so inclined.
```

### Running Locally

Using pnpm to manage things.

```shell
pnpm run dev
```

### Deploying 

I have a deploy script that I run that triggers a build, then does a two phase sync to S3. 

```shell
#!/bin/bash
set -e

if [ -z "$BLOG_BUCKET_NAME" ] || [ -z "$BLOG_DISTRIBUTION_ID" ]; then
  echo "❌ Error: Missing configuration."
  echo "Ensure BLOG_BUCKET_NAME and BLOG_DISTRIBUTION_ID are set in blog/.env"
  exit 1
fi

pnpm install
pnpm run build

aws s3 sync dist/ "s3://${BLOG_BUCKET_NAME}" \
  --delete \
  --exclude ".DS_Store" \
  --exclude "*.html" \
  --exclude "*.xml" \
  --exclude "*.json" \
  --cache-control "public, max-age=31536000, immutable"

aws s3 cp dist/ "s3://${BLOG_BUCKET_NAME}" \
  --recursive \
  --exclude "*" \
  --include "*.html" \
  --include "*.xml" \
  --include "*.txt" \
  --include "*.json" \
  --cache-control "public, max-age=0, must-revalidate"

aws cloudfront create-invalidation \
    --distribution-id "${BLOG_DISTRIBUTION_ID}" \
    --paths "/*"
```

### Post Deploy Checks

Reload [authenticnerd.com](https://authenticnerd.com/) and verify the new content is visible and looks correct. 

While writing this post, I noticed an annoying issue where moving the mouse over the text causes all the links to 
highlight on the page. Oops! Add that to the backog to fix.

### First Impressions

I'm liking this process much better than editing on WordPress! So far, I'm happy with this setup. Let's see how I feel 
about it in a few weeks. 

My least favorite thing when building websites is the look and feel. I started off with auto generated CSS using AI, 
which quickly became a chore. Switching to [Tailwind](https://tailwindcss.com/) made the process of updating the look 
and feel much simpler. The font sizes I have setup might be a bit too large. But I don't know if I want to much with 
it to be honest. I'll leave it like it is for the time being.

It was a bit of fun to setup. Markdown for content heavy websites makes a lot of sense to me. My blog doesn't need much
JavaScript, so pre-compiled web pages work well. By focusing on reducing compiled page sizes, things download fast. 

### Performance

The main page of my blog is approximately 9kB, and downloads in about 300ms. That's with Tailwind CSS inlined into 
each page.

CloudFront caching is configured so that content is cached in S3, and on the client. The CloudFront distribution is 
configured to use http3, and the default caching behaviour has compress set to `true` and caching policy set to 
`Managed-CachingOptimized`. These settings work well for my setup. 
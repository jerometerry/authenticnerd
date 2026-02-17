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

### Blogging. About my own blog?!?

Well this is weird. I'm writing about my blog inside my blog. How, ... meta? 

My blog, [authenticnerd.com](https://authenticnerd.com/), is static content website built using 
[Astro](https://astro.build/). Static web assests are stored in S3, served up from a CloudFront distribution. Deployed 
with Terraform. 

The source for my blog is on [GitHub](https://github.com/jerometerry/my-personal-system/tree/main/blog), if you are so 
inclined.

### The Blogging Process

To create this post, the first thing I did was create a new file markdown file. 

I downloaded an official [Astro brand logo](https://astro.build/press/#assets) and added it to the project at 
`/src/assets/astro-logo-dark.png`. Astro cleverly intercepted right click on their logo on the 
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

My blog, [authenticnerd.com](https://authenticnerd.com/), is static content website built using 
[Astro](https://astro.build/). Static web assests are stored in S3, served up from a CloudFront distribution. Deployed 
with Terraform. 

The source for my blog is on [GitHub](https://github.com/jerometerry/my-personal-system/tree/main/blog), if you are so 
inclined.
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
highlight on the page. Oops! Add that to the backog to fix!


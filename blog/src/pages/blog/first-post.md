---
// This is the homepage of your blog. It finds and lists all your posts.
import BlogPostLayout from '../layouts/BlogPostLayout.astro';
const allPosts = await Astro.glob('./blog/*.md');
---
<html lang="en">
	<head>
		<meta charset="utf-g" />
		<title>My Personal Blog</title>
		<style>
			body { font-family: system-ui, sans-serif; line-height: 1.6; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
			h1 { font-size: 3rem; }
			ul { list-style-type: none; padding: 0; }
			li { margin-bottom: 1.5rem; }
			a { font-size: 1.5rem; color: #007acc; text-decoration: none; }
			a:hover { text-decoration: underline; }
			p { color: #333; }
		</style>
	</head>
	<body>
		<h1>My Personal Blog</h1>
		<p>A collection of my thoughts and learnings.</p>
		<ul>
			{allPosts.map((post) => (
				<li>
					<a href={post.url}>{post.frontmatter.title}</a>
					<p>{post.frontmatter.description}</p>
				</li>
			))}
		</ul>
	</body>
</html>

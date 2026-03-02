#!/bin/bash

# Authentic Nerd Meta Tag Inspector
# Defaults to the Astro generated route sitemap
SITEMAP_URL=${1:-"https://authenticnerd.com/sitemap-0.xml"}

echo "🔍 Fetching sitemap: $SITEMAP_URL"

# Fetch sitemap and use awk to split by <loc> and </loc> tags to extract the URLs cleanly
URLS=$(curl -s "$SITEMAP_URL" | awk -F"<loc>|</loc>" '{for(i=2;i<=NF;i+=2) print $i}')

if [ -z "$URLS" ]; then
    echo "❌ No URLs found. (Check your sitemap URL)"
    exit 1
fi

COUNT=$(echo "$URLS" | wc -w | tr -d ' ')
echo "✅ Found $COUNT pages. Fetching meta tags..."
echo "======================================================="

for URL in $URLS; do
    echo -e "\n📄 $URL"
    
    # 1. Fetch the HTML
    # 2. sed: Force every HTML tag onto its own line (defeats Astro HTML minification)
    # 3. grep: Grab only the SEO/Social tags we care about
    # 4. sed: Clean up any leading whitespace for a pretty output
    curl -s "$URL" \
        | sed 's/>/>\n/g' \
        | grep -iE '<title|<meta.*name="description"|<meta.*property="og:|<meta.*name="twitter:' \
        | sed 's/^[[:blank:]]*//'
        
    echo "-------------------------------------------------------"
    
    # Small delay to keep your CloudFront logs clean
    sleep 0.5 
done

echo -e "\n🎉 Audit Complete!"
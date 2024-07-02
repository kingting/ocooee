#!/bin/bash
set -x

# Ensure the Gemfile exists
cat <<EOF > Gemfile
source "https://rubygems.org"
gem "jekyll"
gem "github-pages", group: :jekyll_plugins
gem 'csv', '~> 3.0'
gem 'webrick', '~> 1.7'

group :jekyll_plugins do
  gem "jekyll-sitemap"
  gem "jekyll-feed"
  gem "jekyll-seo-tag"
end
EOF

# Install bundler if it's not installed
if ! gem spec bundler > /dev/null 2>&1; then
  echo "Installing bundler..."
  gem install bundler
fi

# Install dependencies specified in Gemfile
echo "Installing dependencies..."
bundle install

#----------------------------------------------------------------------------------
# Extract title from README.md
#----------------------------------------------------------------------------------
# Extract the first markdown title (e.g., # Title)
readme_title=$(grep -m 1 '^# ' README.md | sed 's/^# //')

# Fallback title if no title is found
if [ -z "$readme_title" ]; then
  readme_title="Title not found - please create a title # Title"
fi

#----------------------------------------------------------------------------------
# Extract repository name and owner from Git configuration
#----------------------------------------------------------------------------------
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git $REPO_URL)
OWNER_NAME=$(basename $(dirname $REPO_URL))

# Adjust OWNER_NAME and REPO_NAME extraction
OWNER_NAME=${OWNER_NAME##*:}
OWNER_NAME=${OWNER_NAME%%/*}

#----------------------------------------------------------------------------------
# Variables for _config.yml from environment variables
#----------------------------------------------------------------------------------
BASEURL=${BASEURL:-"/${REPO_NAME}"}

#----------------------------------------------------------------------------------
# Generate _config.yml
#----------------------------------------------------------------------------------
echo "Generating _config.yml..."
cat <<EOF > _config.yml
title: ${readme_title}
description: A precise guide providing practical, tried and tested examples.
baseurl: ${BASEURL} # the subpath of your site, e.g. /blog
show_downloads: true
url: "https://${OWNER_NAME}.github.io" # the base hostname & protocol for your site
github:
  is_project_page: true
  repository_url: ${REPO_URL}
  repository_name: ${REPO_NAME}
  owner_url: "https://github.com/${OWNER_NAME}"
  owner_name: ${OWNER_NAME}

# Build settings
markdown: kramdown
remote_theme: pages-themes/cayman@v0.2.0

plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-seo-tag
EOF

#----------------------------------------------------------------------------------
# Generate index.md from README.md
#----------------------------------------------------------------------------------
echo "Generating index.md from README.md..."
cat <<EOF > index.md
---
layout: default
title: $readme_title
---
EOF

cat README.md >> index.md

#----------------------------------------------------------------------------------
# Check if index.md exists
#----------------------------------------------------------------------------------
if [ ! -f index.md ]; then
  echo "index.md not found!"
  exit 1
fi

#----------------------------------------------------------------------------------
# Include javascript 
#----------------------------------------------------------------------------------
echo "" >> index.md
echo "{% raw %}"  >> index.md
echo "<script>" >> index.md
cat scripts/script.js >> index.md
echo "</script>" >> index.md
echo "{% endraw %}"  >> index.md

echo "Jekyll configuration and index.md preparation complete."

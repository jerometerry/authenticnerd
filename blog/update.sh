#!/bin/bash

echo "--- 1. Updating Homebrew ---"
brew update

echo "--- 2. Upgrading outdated brew casks and formulae ---"
brew upgrade

echo "--- 3. Running brew cleanup ---"
brew cleanup

echo "--- 4. Upgrading Astro ---"
pnpm dlx @astrojs/upgrade

echo "--- 5. Upgrading all dependencies ---"
pnpm up
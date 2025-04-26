#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display options to the user
echo -e "${BLUE}========== Marble Website Deployment Tool ==========${NC}"
echo -e "Available options:"
echo -e "  ${GREEN}[Enter]${NC} - Build only, no push"
echo -e "  ${GREEN}y/Y${NC} - Build and push changes"
echo -e "  ${GREEN}n/N${NC} - Build only, no push (same as Enter)"
echo -e "  ${GREEN}p/P${NC} - Push-only mode (no rebuild, just push changes)"
echo -e "${BLUE}=================================================${NC}"

# Ask at the very beginning whether to push
read -p "Do you want to push changes after building the website? (y/N/p): " PUSH_CONFIRM
PUSH_CONFIRM=$(echo "$PUSH_CONFIRM" | tr '[:upper:]' '[:lower:]') # Normalize input

# Handle push-only mode
if [[ "$PUSH_CONFIRM" == "p" ]]; then
  echo -e "${YELLOW}Push-only mode selected. Skipping build process...${NC}"

  # Go directly to pushing changes
  cd /Users/lsanten/Documents/GitHub/LSanten.github.io/docs
  # Set SSH key path
  SSH_KEY="/Users/lsanten/Documents/GitHub/LSanten.github.io/keys/deployment_into_public_website"
  # Create a timestamp commit message
  COMMIT_MSG="Push-only: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Checking status..."
  git status
  echo "Staging all changes..."
  git add .
  echo "Committing with message: '$COMMIT_MSG'"
  git commit -m "$COMMIT_MSG"
  echo "Pushing with deployment SSH key..."
  GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin main
  echo "✅ Push-only operation complete!"
  exit 0
fi

# Store this decision for use at the end
DO_PUSH=false
if [[ "$PUSH_CONFIRM" == "y" || "$PUSH_CONFIRM" == "yes" ]]; then
  DO_PUSH=true
fi

# Continue with build process for any other options (Enter, n, N, etc.)

# Ensure you are in the project root
cd /Users/lsanten/Documents/GitHub/LSanten.github.io

# Activate the virtual environment
source venv/bin/activate

# Run python scripts to process _mms-md
python3 python/generate-all-file.py
python3 python/add-headers.py
python3 python/add-title-subtitle_frontmatter.py
python3 python/add-YAML-frontmatter-for-files-without-creation-and-modified-frontmatter.py
python3 python/first-image-preview-directory-creation-and-downsizing.py

# Build the Jekyll site
jekyll build --destination docs

# Copy manual files into docs
cp -r manual_files/* docs/

# Add magic symbol to internal links
python3 python/add-magic-symbol.py

# Optionally push the site
if $DO_PUSH; then
  cd /Users/lsanten/Documents/GitHub/LSanten.github.io/docs
  # Set SSH key path
  SSH_KEY="/Users/lsanten/Documents/GitHub/LSanten.github.io/keys/deployment_into_public_website"
  # Create a timestamp commit message
  COMMIT_MSG="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Checking status..."
  git status
  echo "Staging all changes..."
  git add .
  echo "Committing with message: '$COMMIT_MSG'"
  git commit -m "$COMMIT_MSG"
  echo "Pushing with deployment SSH key..."
  GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin main
  echo "✅ Deployment complete!"
else
  echo "ℹ️  Skipping push as requested."
fi

# Deactivate the virtual environment
deactivate

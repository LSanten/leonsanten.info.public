#!/bin/bash

# Ensure you are in the project root
cd /Users/lsanten/Documents/GitHub/LSanten.github.io


# Activate the virtual environment
source venv/bin/activate

# Run python scripts to scan _mms-md folder

python3 python/generate-all-file.py # Generate file called ALL.md that contains a list of all .md files in the folder
python3 python/add-headers.py # Add headers with template = default settings if it doesn't exist (needs to be after the generate-all-file)
python3 python/add-title-subtitle_frontmatter.py # Add title and subtitle to YAML and update changes
python3 python/add-YAML-frontmatter-for-files-without-creation-and-modified-frontmatter.py # Checks all files for creation, modified, and display settings and adds sections respectively if they don't exist
python3 python/first-image-preview-directory-creation-and-downsizing.py # Create og:image resized images for large images and directory for all first images


# Build the Jekyll site
jekyll build --destination docs

# Copy manual files into docs
cp -r manual_files/* docs/

# Add magic symbol to internal links
python3 python/add-magic-symbol.py # Add headers with template settings if it doesn't exist (needs to be after the generate-all-file)

# Commit and push to the repository
#git add docs
#git commit -m "Deploying site with manual files"
#git push origin main


# Execute by running
# ./build_and_deploy.sh
#
cd /Users/lsanten/Documents/GitHub/LSanten.github.io/docs

# Set SSH key path
SSH_KEY="/Users/lsanten/Documents/GitHub/LSanten.github.io/keys/deployment_into_public_website"

# Create a timestamp commit message
COMMIT_MSG="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"

# Run git steps
echo "Checking status..."
git status

echo "Staging all changes..."
git add .

echo "Committing with message: '$COMMIT_MSG'"
git commit -m "$COMMIT_MSG"

echo "Pushing with deployment SSH key..."
GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin main

echo "✅ Deployment complete!"



# Deactivate the virtual environment
deactivate

#!/bin/bash
# Make sure you're in the main repository directory
cd /Users/lsanten/Documents/GitHub/LSanten.github.io

# 1. First, let's check what's in the .git file in docs
echo "Contents of docs/.git:"
cat docs/.git

# 2. Deinitialize the existing broken submodule connection
echo "Deinitializing submodule..."
git submodule deinit -f docs

# 3. Remove the submodule's entry from .git/config
echo "Removing submodule from .git/config..."
git config --remove-section submodule.docs 2>/dev/null || echo "No docs section in .git/config"

# 4. Clear any cached entries
echo "Clearing git cache..."
git rm --cached docs

# 5. Reinitialize the modules from the existing .gitmodules file
echo "Reinitializing submodule..."
git submodule init

# 6. Fix the URL if needed (check if it matches what's in .gitmodules)
echo "Setting submodule URL..."
git config submodule.docs.url https://github.com/LSanten/leonsanten.info.public.git

# 7. Update the submodule - this will clone the repository into docs
echo "Updating submodule..."
git submodule update

# 8. Verify the submodule status
echo "Checking submodule status:"
git submodule status

# 9. Go into docs and make sure it's on the right branch
echo "Setting up docs submodule..."
cd docs
git checkout main
git status

# 10. Check that it's a proper git repository
echo "Testing if docs is a proper git repository..."
if [ -d ".git" ]; then
    echo "docs has a .git directory - this is unexpected for a submodule"
elif [ -f ".git" ]; then
    echo "docs has a .git file - this is normal for a submodule"
    echo "Content: $(cat .git)"
else
    echo "No .git file or directory found - something is wrong"
fi

# 11. Try to run a git command to verify the repository works
echo "Testing git functionality in docs..."
git log -1 --oneline
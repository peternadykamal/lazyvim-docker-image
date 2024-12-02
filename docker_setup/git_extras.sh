#!/bin/bash

# Clone the git-extras repository into /tmp
cd /tmp
git clone https://github.com/tj/git-extras.git

# Change to the git-extras directory
cd git-extras

# Checkout the latest tag
git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

# Install git-extras
make install

# Clean up by removing the cloned repository
cd ..
rm -rf git-extras
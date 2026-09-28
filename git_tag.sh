#!/bin/bash
set -euo pipefail

## 1. Check if there are uncommitted changes, if not proceed. If there are, notify and exit.
if ! git diff-index --quiet HEAD --; then
    echo "Error: There are uncommitted (staged or unstaged) changes in the working tree. Please stash or commit them before proceeding."
    exit 1
fi

## 2. Switch active branch to main if not already in main.
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
    echo "Switching active branch from '$current_branch' to 'main'..."
    git checkout main
fi

git merge dev

## 3. Check if the latest commit already has a tag associated with it
if [ -n "$(git tag --points-at HEAD)" ]; then
    echo "Error: The latest commit on 'main' already has a tag associated with it. Aborting."
    exit 1
fi

echo "Merging dev branch into main..."
git merge dev

## Extract the VERSION and remove spaces/carriage returns
version="$(date -u +'%y.%m.%d')"
if [ -z "$version" ]; then
    echo "Error: Extracted version is empty."
    exit 1
fi

tag_name="v$version"
echo "Detected Docker Image version: $version"

## 4. Check if the tag of v{VERSION} does not already exist. If it does, print a message and exit.
## Check local tags
if git rev-parse "$tag_name" >/dev/null 2>&1; then
    echo "Error: Tag '$tag_name' already exists locally."
    exit 1
fi

## Check remote tags
if git ls-remote --tags origin "$tag_name" | grep -q "$tag_name"; then
    echo "Error: Tag '$tag_name' already exists on the remote repository."
    exit 1
fi

## 5. Tag the latest commit in pre-selected main branch with v{VERSION} tag.
echo "Tagging the latest commit on main with '$tag_name'..."
git tag -a "$tag_name" -m "Uses openresty docker image version: $version"

## 6. Push the commit & the tags to remote repo.
echo "Pushing main branch and tag '$tag_name' to remote..."
git push origin main
git push origin "$tag_name"

echo "Successfully tagged and pushed '$tag_name'!"

#!/usr/bin/env bash

trunk="origin/develop"
echo "--------------------------------"
echo "Branch Name: '$BRANCH'"
echo "--------------------------------"
branch_prefix=${BRANCH%%/*}
branch_suffix=${BRANCH##*/}
echo "Branch Prefix: ${branch_prefix}"
echo "Branch Suffix: ${branch_suffix}"
if [ "${branch_suffix}" != "develop" ]; then
    echo "Branch Build Detected."
    echo "Getting parent branch commit and tag"
    parent_commit_dirty=$(git rev-list "${trunk}..${BRANCH}" --boundary | grep "^-" | tail -n1)
    parent_commit="${parent_commit_dirty:1}"
    echo "Parent commit: '${parent_commit}'"

    echo "Getting tag associated with parent commit"
    parent_tag=$(git describe --exact-match "${parent_commit}")
    echo "Parent tag: '${parent_tag}'"

    # Artifactory will not allow artifacts with underscores in their name
    echo "Replacing underscores in branch name"
    branch_suffix=$(echo $branch_suffix | sed -e "s/_/-/g")
    echo "Using branch name $branch_suffix"

    echo "Building tag name from parent tag, and commit hash"
    git_commit_hash=$(git rev-parse HEAD)
    # Trim commit hash to only have 7 characters
    git_commit_hash=$(echo "${git_commit_hash}" | awk '{print substr($0,0,7)}')
    additional_suffix="-${git_commit_hash}-${branch_suffix}"
    new_tag="${parent_tag}${additional_suffix}"
    echo "${parent_tag} -> ${new_tag}"

    echo "${new_tag}" > new_build_number.txt
    echo "${parent_tag}" > last_build_number.txt
    exit 0
else
    echo "Develop (trunk) branch detected."
    echo "Ignoring 99.x.x.x tags."
    tag_regex="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
    ignore_tag_regex="99\.0\."
fi

get_latest_tag(){
    declare -ag versions
    declare -g latest_tag
    # Get latest tag but not 99.x
    latest_tag=$(git tag | grep -E "${tag_regex}" | grep -v "${ignore_tag_regex}" | sort -V | tail -1)
    echo "Current tag: '${latest_tag}'"
    if [ -n "${latest_tag}" ]; then
        IFS='.' read -ra versions <<< "${latest_tag}"
    else
        echo "Current tag returned empty! Exiting."
        exit 1
    fi
}

get_latest_tag
echo "Attempting to update tag"
num_versions="${#versions[@]}"
echo "Tag ${latest_tag} has ${num_versions} version numbers."
if [ "${num_versions}" == "4" ]; then
    echo "Automatically incrementing version!"
    first="${versions[0]}"
    second="${versions[1]}"
    third="${versions[2]}"
    fourth="${versions[3]}"
    bumped_fourth=$((fourth + 1))
    new_tag="${first}.${second}.${third}.${bumped_fourth}"
    echo "${latest_tag} -> ${new_tag}"
    # Output build number for consumption by github actions
    echo "${new_tag}" > new_build_number.txt
    echo "${latest_tag}" > last_build_number.txt
else
    echo "Tag ${latest_tag} does not adhere to versioning schema!"
    echo "Expected 4 version numbers: Not updating tag"
    exit 1
fi

echo "autotag.sh Complete."

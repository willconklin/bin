#!/usr/bin/env bash

tag_annotation="CI Release"

push_new_tag(){
    echo "Attempting to push new tag to GitHub: ${1}"
    git tag -a "${1}" -m "${tag_annotation}"
    check_exit_code "$?"
    git push origin : "${1}"
    check_exit_code "$?"
}

check_exit_code(){
    exit_code="$1"
    if [ "${exit_code}" != "0" ]; then
        echo "Unable to push tag! Got exit code ${exit_code}"
        exit "${exit_code}"
    fi
}

push_new_tag "${1}"

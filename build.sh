#!/bin/sh

#################################################################################
# Description:
#   This script serves the purpose to trigger a build on API request on
#   the Travis CI platform for the commits that don't have the .travis.yml file.
#
# Usage:
#   sh build.sh -b 'BRANCH' -t 'TOKEN' -c 'COMMIT-SHA' -r 'REPOSITORY-SLUG'
#
# where:
#   -b = branch
#   -c = commit SHA
#   -r = repo slug (in format username%2Frepo)
#   -t = Travis CI API auth Token (https://app.travis-ci.com/account/preferences)
#################################################################################

while getopts c:b:r:t: flag
do
    case "${flag}" in
        c) commit=${OPTARG};;
        b) branch=${OPTARG};;
        r) repo=${OPTARG};;
        t) token=${OPTARG};;
    esac
done

[[ -z "$commit" ]] && echo "Empty or no Commit SHA provided! Please use -c 'COMMIT-SHA'" && exit 1
[[ -z "$branch" ]] && echo "Empty or no Branch name provided! Please use -b 'BRANCH-NAME'" && exit 1
[[ -z "$repo" ]] && echo "Empty or no Repo Slug provided! Please use -r 'REPO-SLUG'" && exit 1
[[ -z "$token" ]] && echo "Empty or no Travis CI Token provided! Please use -t 'TRAVIS-API-TOKEN'" && exit 1

echo "Triggering an API build on Travis CI for commit $commit on branch $branch for repo $repo"

# Change the config to desired, use https://config.travis-ci.com/explore to get Parsed and validated config.
body='{
 "request": {
 "message": "API request build",
 "branch":"'$branch'",
 "sha":"'$commit'",
 "config": {
   "os": "linux",
   "dist": "xenial",
   "arch": "arm64",
   "language": "shell",
   "install": "skip",
   "script": "true"
  }
}}'

curl -s -X POST \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Travis-API-Version: 3" \
 -H "Authorization: token $token" \
 -d "$body" \
 https://api.travis-ci.com/repo/$repo/requests

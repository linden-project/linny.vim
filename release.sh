#!/bin/bash

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# v1.0.0, v1.5.2, etc.
versionLabel=v$1

# establish branch and tag name variables
devBranch=develop
masterBranch=master
releaseBranch=release-$versionLabel

# create the release branch from the -develop branch
git checkout -b $releaseBranch $devBranch

# file in which to update version number
versionFile="VERSION.txt"

# find version number assignment ("= v1.5.5" for example)
# and replace it with newly specified version number
sed -i.backup -E "s/\= v[0-9.]+/\= $versionLabel/" $versionFile $versionFile

# remove backup file created by sed command
rm $versionFile.backup

# commit version number increment
git commit -am "Incrementing version number to $versionLabel"

# merge release branch with the new version number into master
git checkout $masterBranch
git merge --no-ff $releaseBranch

# create tag for new version from -master
git tag $versionLabel

# merge release branch with the new version number back into develop
git checkout $devBranch
git merge --no-ff $releaseBranch

# remove release branch
git branch -d $releaseBranch

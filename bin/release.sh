#!/bin/bash

set -o nounset
set -o errexit

echo "Analyzing project..."

CURRENT_BRANCH=`git symbolic-ref HEAD | sed -e 's/refs\/heads\///'`
if [ "${CURRENT_BRANCH}" == "master" ]; then
  echo "YOU MUST NOT BE ON master BRANCH!"
  exit 1
fi

VERSION=$( mvn help:evaluate -Dexpression=project.version | grep "^[0-9]\+\.[0-9]\+\.[0-9]\+\(-SNAPSHOT\)\?$" | head -n1 | sed -e 's/-SNAPSHOT$//' )

RELEASE_NAME=$( mvn help:evaluate -Dexpression=project.artifactId | grep "^[A-Za-z0-9_-]\+$" | head -n1 )

read -p "Enter name for release: " -e -i "${RELEASE_NAME}" RELEASE_NAME

read -p "Enter release version: " -e -i "${VERSION}" VERSION

RELEASE_BRANCH="release-${VERSION}"

TAG="${RELEASE_NAME}-${VERSION}"

LOG="release.log"

echo
echo "Using release branch: ${RELEASE_BRANCH}"
echo "Using release tag: ${TAG}"
echo "Logging to: ${LOG}"
echo

if [ -f "${LOG}" ]; then
  read -p "Log already exists, delete it (y/n)? " -e -i "y"
  [ "$REPLY" == "y" ] && rm ${LOG}
  echo
fi

echo "Press enter to continue (Ctrl-C to abort)"
read

function execute {
  CMD=$1
  echo >> ${LOG}
  echo "== $1" >> ${LOG}
  echo >> ${LOG}
  ${CMD}
  echo >> ${LOG}
}

echo
echo "... Cleaning"
echo
execute "mvn clean"

echo
echo "... Preparing release"
echo
execute "git checkout -b ${RELEASE_BRANCH}"
execute "mvn release:prepare -DlocalCheckout=true -DautoVersionSubmodules=true -DpushChanges=false"

echo
echo "... Performing release"
echo
execute "mvn release:perform -DlocalCheckout=true -DpushChanges=false -Darguments=-DaltDeploymentRepository=osr-public-releases-deployment::default::file:///tmp/deployment-repo"

echo
echo "... Fixing release tag"
echo
execute "git checkout master"
execute "git merge --no-ff ${TAG}"
execute "git tag -f ${TAG} master"

echo
echo "... Continuing develop branch"
echo
execute "git checkout develop"
execute "git merge --no-ff ${RELEASE_BRANCH}"
execute "git branch -d ${RELEASE_BRANCH}"

echo
echo "... Deploying first snapshot of new development cycle"
echo
execute "mvn deploy"

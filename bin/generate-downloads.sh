#!/bin/bash

set -o nounset
set -o errexit

echo "Analyzing project..."

CURRENT_BRANCH=`git symbolic-ref HEAD | sed -e 's/refs\/heads\///'`

VERSION=$( mvn help:evaluate -Dexpression=project.version | grep "^[0-9]\+\.[0-9]\+\.[0-9]\+\(-SNAPSHOT\)\?$" | head -n1 | sed -e 's/-SNAPSHOT$//' )

RELEASE_NAME=$( mvn help:evaluate -Dexpression=project.artifactId | grep "^[A-Za-z0-9_-]\+$" | head -n1 )

COMMIT_ID=$( git rev-parse HEAD )

if [[ -z $CURRENT_BRANCH ]] || [[ -z $VERSION ]] || [[ -z $RELEASE_NAME ]] || [[ -z $COMMIT_ID ]]; then
	exit
fi

DATE=$(date -u +%Y%m%d-%H%M)

BRANCH_DIR="downloads/${RELEASE_NAME}/${CURRENT_BRANCH}-${VERSION}"

COMMIT_DIR_NAME="${DATE}-${COMMIT_ID}"

TARGET="${BRANCH_DIR}/${COMMIT_DIR_NAME}"

# ------------------------------------------------------------------------------

echo; echo "____ CLEAN _____________________________________________________________________"; echo
mvn clean

echo; echo "____ PACKAGE ___________________________________________________________________"; echo
mvn package

echo; echo "____ JAVADOC ___________________________________________________________________"; echo
mvn javadoc:aggregate-jar

echo; echo "____ SOURCE ____________________________________________________________________"; echo
mvn source:aggregate

mkdir -p "$TARGET"

cp target/${RELEASE_NAME}-*-{javadoc,sources}.jar "${TARGET}"

cp sweble-wikitext/swc-parser-lazy/target/swc-parser-lazy-*-jar-with-dependencies.jar "${TARGET}/"

cp sweble-wikitext/swc-engine/target/swc-engine-*-jar-with-dependencies.jar "${TARGET}/"

ln -s "${COMMIT_DIR_NAME}" "${BRANCH_DIR}/latest"

# ------------------------------------------------------------------------------

STATUS=$( git submodule status )

function artifact() {
	basename `find "$TARGET"/$1`
}

MSG=$(cat <<EOM

$( artifact "swc-devel-*-javadoc.jar" ):

  The javadoc for all projects subsumed in the swc-devel meta project.
  This JAR does not include the javadoc of dependencies.

$( artifact "swc-devel-*-sources.jar" ):

  The sources of all projects subsumed in the swc-devel meta project.
  This JAR does not include the sources of dependencies.

$( artifact "swc-parser-lazy-*-jar-with-dependencies.jar" ):

  Binary JAR of the swc-parser-lazy project including ALL dependencies.

$( artifact "swc-engine-*-jar-with-dependencies.jar" ):

  Binary JAR of the swc-engine project including ALL dependencies.
  This also includes the lazy parser.

Commit IDs of the individual modules:

$( echo "${STATUS}" | sed "s/^[ ]*/  /" )

EOM
)

echo "${MSG}" > "${TARGET}/README"

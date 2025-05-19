#!/bin/bash -x
#

## download hugo content project
git clone ${HUGO_GIT_PROJECT_URL} ${HUGO_GIT_PROJECT_NAME}
cd ${HUGO_GIT_PROJECT_NAME}

## build project
hugo "$@"

## copy the build contents to the given destination
exec rsync -r --exclude ".git" public/. ${HUGO_CONTENTS_DEST_PATH}/.

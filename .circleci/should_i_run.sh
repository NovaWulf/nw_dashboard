#!/bin/bash

shouldIRun() {
  # branch=`git rev-parse --abbrev-ref HEAD`
  appString=$1
  apps=(${appString//,/ }) #https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
  CIRCLE_COMPARE_URL=$2

  halt=true

  echo "CIRCLE_COMPARE_URL: $CIRCLE_COMPARE_URL"

  COMMIT_RANGE=$(echo $CIRCLE_COMPARE_URL | sed 's:^.*/compare/::g')

  echo "Commit range: $COMMIT_RANGE"

  # Fix single commit, unfortunately we don't always get a commit range from Circle CI
  if [[ $COMMIT_RANGE != *"..."* ]]; then
    COMMIT_RANGE="${COMMIT_RANGE}...${COMMIT_RANGE}"
  fi

  echo git diff --name-only $COMMIT_RANGE #origin/master...$branch

  if git diff --name-only $COMMIT_RANGE | grep "^.circleci" ; then
    echo "Should I Run: Yes, Circle config has been modified"
    halt=false
  else
    for app in "${apps[@]}"
    do
      if git diff --name-only $COMMIT_RANGE | grep "^${app}" ; then
        echo "Should I Run: Yes, $app has been modified"
        halt=false
      fi
    done
  fi

  if [ "$halt" = true ] ; then
    echo "Should I Run: No relevant files were changed.  HALTING this job."
    circleci step halt
  fi
}

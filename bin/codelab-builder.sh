#!/bin/bash
#
# Watches the patient-lists.md file for changes, automatically refreshing the
# docs folder.
#
# Usage: ./bin/codelab-builder.sh
#
set -e
set -u

function already() {
  echo "'${1}' already running"
  exit 1
}

# Sanity checks.
type claat kqwait  &>/dev/null  # Fails if either is not installed.

# Launch the native web server from within the docs folder.
cd "$( dirname "${0}" )/../docs"
ps aux | grep claat | grep -q serve && already "claat serve"
claat serve &
trap "kill $!" EXIT
cd ..

# This is the codelab source file to watch.
CODELAB=./codelab/patient-lists.md

# Prevent two watchers from running at once.
ps aux | grep kqwait | grep -q "${CODELAB}" && already "kqwait $CODELAB"
ps aux | grep claat | grep -q export && already "claat export"

# Watch the codelab for changes, exporting on each one.
echo "Press ^C to quit:"
while kqwait "$CODELAB" && claat export $_ || true; do continue; done

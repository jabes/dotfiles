#!/usr/bin/env bash

# A simple script to backup an organization's GitHub repositories.
function github-backup() {
  local GHBU_BACKUP_DIR=${GHBU_BACKUP_DIR-"$HOME/CloudStation/Repositories"}       # where to place the backup files
  local GHBU_UNAME=${GHBU_UNAME-"jabes"}                                           # the username of a GitHub account (to use with the GitHub API)
  local GHBU_GITHOST=${GHBU_GITHOST-"github.com"}                                  # the GitHub hostname (see comments)
  local GHBU_API=${GHBU_API-"https://api.github.com/user/repos?affiliation=owner"} # base URI for the GitHub API
  local GHBU_PRUNE_OLD=${GHBU_PRUNE_OLD-true}                                      # when `true`, old backups will be deleted
  local GHBU_PRUNE_AFTER_N_DAYS=${GHBU_PRUNE_AFTER_N_DAYS-3}                       # the min age (in days) of backup files to delete

  # Define local vars
  local RESPONSE
  local HTTP_CODE
  local HTTP_BODY
  local REPO_LIST
  local REPO_TOTAL
  local TIMESTAMP
  local CLONE_PATH
  local PRUNE_LIST
  local PRUNE_TOTAL

  echo "" && echo "=== INITIALIZING ===" && echo ""
  echo "Using backup directory $GHBU_BACKUP_DIR"
  mkdir --parents "$GHBU_BACKUP_DIR"

  echo "Fetching list of repositories for $GHBU_UNAME..."
  RESPONSE=$(curl --silent --write-out '%{http_code}' --user "$GHBU_UNAME" "$GHBU_API")
  HTTP_CODE="${RESPONSE:${#RESPONSE}-3}"
  HTTP_BODY="${RESPONSE:0:${#RESPONSE}-3}"

  if [[ "$HTTP_CODE" != 200 ]]; then
    echo "An error occurred."
    echo "$HTTP_BODY" | jq --raw-output '.message'
    return
  fi

  REPO_LIST=$(echo "$HTTP_BODY" | jq --raw-output '.[].name')
  REPO_TOTAL=$(echo "$REPO_LIST" | wc --lines)
  echo "Found $REPO_TOTAL repositories."

  echo "" && echo "=== BACKING UP ===" && echo ""
  echo "$REPO_LIST" | while read -r REPO; do
    echo "Backing up $GHBU_UNAME/$REPO"
    TIMESTAMP=$(date "+%Y%m%d-%H%M")
    CLONE_PATH="$GHBU_BACKUP_DIR/$GHBU_UNAME-$REPO-$TIMESTAMP.git"
    git clone --quiet --mirror "git@${GHBU_GITHOST}:${GHBU_UNAME}/${REPO}.git" "$CLONE_PATH"
    tar --gzip --create --file="${CLONE_PATH}.tar.gz" --directory="$CLONE_PATH" . && rm --recursive --force "$CLONE_PATH"
  done

  if [[ "$GHBU_PRUNE_OLD" == "true" ]]; then
    echo "" && echo "=== PRUNING ===" && echo ""
    echo "Pruning backup files $GHBU_PRUNE_AFTER_N_DAYS days old or older."
    PRUNE_LIST=$(find "$GHBU_BACKUP_DIR" -name '*.tar.gz' -mtime "+${GHBU_PRUNE_AFTER_N_DAYS}")
    PRUNE_TOTAL=$(echo "$PRUNE_LIST" | awk NF | wc --lines)
    echo "Found $PRUNE_TOTAL files to prune."
    echo "$PRUNE_LIST" | while read -r FILE; do
      rm --force --verbose "$FILE"
    done
  fi

  echo "" && echo "=== DONE ===" && echo ""
  echo "GitHub backup completed." && echo ""
}

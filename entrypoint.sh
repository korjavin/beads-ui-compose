#!/bin/sh
set -e

if [ -n "$GIT_REPO_URL" ]; then
  echo "Configuring git..."
  git config --global user.name "${GIT_USER_NAME:-beads-ui-bot}"
  git config --global user.email "${GIT_USER_EMAIL:-bot@beads-ui.local}"

  # To avoid issues with volume permissions
  git config --global --add safe.directory /data

  if [ ! -d "/data/.git" ]; then
    echo "Cloning repository from $GIT_REPO_URL..."
    # Ensure directory is empty before cloning
    rm -rf /data/* /data/.* 2>/dev/null || true
    git clone "$GIT_REPO_URL" /data
  else
    echo "Repository already exists, pulling latest changes..."
    cd /data && git pull origin ${GIT_BRANCH:-main}
  fi

  # Bootstrap beads database if needed (clones dolt data from git)
  if [ -d "/data/.beads" ] && [ ! -d "/data/.beads/embeddeddolt" ]; then
    echo "Bootstrapping beads database..."
    cd /data && bd bootstrap || true
  fi

  # Ensure the Dolt remote uses the authenticated URL for pushing
  if [ -d "/data/.beads" ]; then
    cd /data
    bd dolt remote remove origin 2>/dev/null || true
    bd dolt remote add origin "git+${GIT_REPO_URL}"
  fi
  
  if [ "$SYNC_ENABLED" = "true" ]; then
    echo "Starting background sync loop (Interval: ${SYNC_INTERVAL:-60}s)..."
    (
      while true; do
        sleep ${SYNC_INTERVAL:-60}
        cd /data
        git add .
        # Only commit if there are changes
        if ! git diff-index --quiet HEAD; then
          git commit -m "Auto-sync from beads-ui"
          git pull --rebase origin ${GIT_BRANCH:-main}
          git push origin ${GIT_BRANCH:-main}
          echo "Changes synced to GitHub."
        fi
        
        # Sync dolt database to remote if it exists
        if [ -d "/data/.beads" ]; then
          bd dolt pull origin || true
          bd dolt push || true
        fi
      done
    ) &
  fi
fi

echo "Starting Beads UI server in foreground..."
cd /data
exec node $(npm root -g)/beads-ui/server/index.js --host 0.0.0.0 --port 3000

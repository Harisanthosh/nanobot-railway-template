#!/bin/bash
set -e

mkdir -p /data/.nanobot/workspace/skills
mkdir -p /data/.nanobot/sessions
mkdir -p /data/.nanobot/cron

# --- Sync agent files from repo into persistent workspace (always overwrites on deploy) ---

# Global agent identity
if [ -f /app/agents/AGENTS.md ]; then
  cp /app/agents/AGENTS.md /data/.nanobot/workspace/AGENTS.md
  echo "[start.sh] Installed AGENTS.md"
fi

# Skills — copy each skill directory so updates deploy cleanly
if [ -d /app/agents/skills ]; then
  for skill_dir in /app/agents/skills/*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "/data/.nanobot/workspace/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "/data/.nanobot/workspace/skills/$skill_name/SKILL.md"
    echo "[start.sh] Installed skill: $skill_name"
  done
fi

# --- Seed cron jobs only if the store does not exist yet ---
# To re-seed: delete /data/.nanobot/cron/jobs.json and restart
if [ ! -f /data/.nanobot/cron/jobs.json ] && [ -f /app/cron/jobs.json ]; then
  cp /app/cron/jobs.json /data/.nanobot/cron/jobs.json
  echo "[start.sh] Seeded cron jobs from template (jobs are disabled — configure channel IDs to enable)"
fi

exec python /app/server.py

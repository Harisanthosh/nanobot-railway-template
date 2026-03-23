---
name: dev-reviewer
description: Automated GitHub commit review for student submissions in Think_AI_With_Blitzwork, writes feedback.txt per submission
always: false
---

# Dev Reviewer Skill

## Purpose
Review new student code submissions committed to `Harisanthosh/Think_AI_With_Blitzwork` under the `Tutorials/Submissions/` directory. For each new or changed submission, produce a `feedback.txt` file and commit it back to the repo, then post a summary to the Discord #dev channel.

## Prerequisites
- `GITHUB_TOKEN` environment variable must be set (Railway variable) with `repo` scope.
- `git` is available in the container.

## Execution Steps

### 1. Clone / Update the Repository

```bash
# Set up git identity
git config --global user.email "blitz-bot@blitzwork.ai"
git config --global user.name "Blitz AI Reviewer"

# Clone if not already present, otherwise pull latest
REPO_DIR="/data/.nanobot/workspace/think-ai"
if [ -d "$REPO_DIR/.git" ]; then
  cd "$REPO_DIR" && git pull --rebase
else
  git clone "https://x-access-token:$GITHUB_TOKEN@github.com/Harisanthosh/Think_AI_With_Blitzwork.git" "$REPO_DIR"
  cd "$REPO_DIR"
fi
```

Use `exec` to run these commands.

### 2. Discover New / Changed Submissions

```bash
# List files changed in the last 12 hours in Tutorials/Submissions
cd /data/.nanobot/workspace/think-ai
git log --since="12 hours ago" --name-only --pretty=format:"" -- "Tutorials/Submissions/**" | sort -u | grep -v '^$' | grep -v 'feedback.txt'
```

This gives you the list of submission files to review.

### 3. Review Each Submission

For each file path returned:
1. Use `read_file` to read the file content.
2. Perform a thorough code review covering:
   - **Correctness**: Does the code solve the stated problem? Are there logic errors?
   - **Code Quality**: Naming, structure, readability, DRY principles.
   - **Security**: Any obvious vulnerabilities (hardcoded secrets, injection risks, unsafe evals).
   - **Best Practices**: Proper error handling, typing hints (Python), comments where needed.
   - **Learning Feedback**: Positive encouragement + specific, actionable improvements.

### 4. Write feedback.txt

Determine the feedback file path:
```
Tutorials/Submissions/{student_folder}/feedback.txt
```
If the submission is at `Tutorials/Submissions/alice/week1/solution.py`, write feedback to `Tutorials/Submissions/alice/week1/feedback.txt`.

Format the feedback as:

```
# Code Review Feedback
Reviewed by: Blitz AI Reviewer
Date: {YYYY-MM-DD HH:MM UTC}
File reviewed: {relative path}

## Summary
{2-3 sentence overall assessment}

## Strengths ✅
- {point 1}
- {point 2}

## Areas for Improvement 🔧
- {point 1 with example fix if possible}
- {point 2}

## Security Notes 🔒
- {any security concerns, or "No issues found"}

## Next Steps
{1-2 actionable suggestions for the student}

---
Keep going! Great effort on this submission. 🚀
```

Use `write_file` to write the feedback file.

### 5. Commit and Push Feedback

```bash
cd /data/.nanobot/workspace/think-ai
git add Tutorials/Submissions/
git commit -m "bot: add review feedback for {submission_path} [{date}]"
git push "https://x-access-token:$GITHUB_TOKEN@github.com/Harisanthosh/Think_AI_With_Blitzwork.git" HEAD:main
```

Use `exec` to run these commands. If there is nothing new to commit, skip with a log message.

### 6. Post Summary to #dev Channel

After processing all submissions, build a summary and post it using the `message` tool:

```
🔍 **Blitz Code Review Run — {DATE} {TIME} UTC**

Reviewed **{N}** new submission(s):

{For each submission:}
👤 **{student_name}** — `{filename}`
  Key feedback: {1-sentence summary of main finding}

📝 Feedback files committed to the repo.
```

Post to `channel=discord` with `to={DEV_CHANNEL_ID}`.

If no new submissions were found, post:
```
✅ **Dev Review — {DATE}**: No new submissions since last check. Repo is up to date.
```

## Error Handling
- If `GITHUB_TOKEN` is missing: log error and post to #dev "⚠️ GITHUB_TOKEN not set — cannot run dev review."
- If git push fails: log the error, still post the feedback summary noting the push failed.
- If a file is too large (>50KB): skip detailed review, post "File too large for automated review — manual review needed."

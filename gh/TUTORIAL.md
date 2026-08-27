# GitHub CLI (gh) - Quick Reference

## Install

### One-liner
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shandiprill/scripts/main/gh/setup-gh.sh)"
```

### Local
```bash
bash setup-gh.sh
```

## Authentication
```bash
gh auth login
# Choose: HTTPS (recommended for LXC)
# Token from: https://github.com/settings/tokens?type=beta
```

## Repositories
- Clone: `gh repo clone username/repo`
- Create: `gh repo create myrepo --public`
- List: `gh repo list`
- View: `gh repo view`
- Fork: `gh repo fork username/repo --clone`

## Pull Requests
- Create: `gh pr create --title "Fix bug"`
- List: `gh pr list`
- View: `gh pr view 42`
- Checkout: `gh pr checkout 42`
- Approve: `gh pr review 42 --approve`
- Merge: `gh pr merge 42 --squash`
- Close: `gh pr close 42`

## Issues
- Create: `gh issue create --title "Bug found"`
- List: `gh issue list`
- View: `gh issue view 10`
- Comment: `gh issue comment 10 --body "message"`
- Close: `gh issue close 10`
- Edit: `gh issue edit 10 --add-label "bug"`

## Releases
- Create: `gh release create v1.0.0`
- List: `gh release list`
- Download: `gh release download v1.0.0 --pattern "*.tar.gz"`

## Common Workflows

### Complete Development Flow
```bash
# 1. Clone
gh repo clone username/myrepo && cd myrepo

# 2. Create branch
git checkout -b feature/new

# 3. Make changes
echo "code" > file.js && git add . && git commit -m "Add feature"

# 4. Push & Create PR
git push -u origin feature/new
gh pr create --title "Add feature" --body "Description"

# 5. Review & Merge
gh pr view --comments
gh pr merge --squash
```

### Bug Report
```bash
gh issue create --title "Bug: login fails" --body "Steps to reproduce..." --web
```

### Review PR
```bash
gh pr checkout 42
git diff main..
gh pr review 42 --approve
```

## Tips
- Add `--web` to most commands to open in browser
- Use `@me` for current user: `gh pr list --assignee @me`
- JSON output: `gh pr list --json number,title`
- Create aliases: `gh alias set prs 'pr list --author @me'`

## Configuration
- Status: `gh auth status`
- Protocol: `gh config set git_protocol https`
- Editor: `gh config set editor vim`
- List config: `gh config list`

## Help
- Commands: `gh help`
- Specific: `gh <command> --help`
- Docs: https://cli.github.com/manual

For full guide, visit: https://github.com/shandiprill/scripts/blob/main/gh/TUTORIAL.md

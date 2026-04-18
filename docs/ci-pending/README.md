# CI workflow staged here pending `workflow` token scope

`ci.yml` lives here instead of `.github/workflows/` because the PAT used for
the first push to `github.com/pwjdev-del/Ladder` did not have the `workflow`
scope, and GitHub refuses to accept workflow files from a token without it.

To activate CI:

```sh
# Option 1 — refresh gh token with workflow scope (interactive)
gh auth refresh -s workflow -h github.com

# Option 2 — fine-grained PAT with "Actions" workflows permission
# https://github.com/settings/tokens?type=beta

# Then:
cd LadderApp
git mv docs/ci-pending/ci.yml .github/workflows/ci.yml
git commit -m "ci: activate workflow after token scope upgrade"
git push
```

Workflow content is unchanged — isolate attack suite, lint, iOS build+test,
backend tests, PR-comment bot.

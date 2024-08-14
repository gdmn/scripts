#! /usr/bin/env bash

git rebase -i $(git show-branch --merge-base)

# rebase with main branch:
# git rebase -i $(git merge-base $(git config --get init.defaultBranch || echo master) $(git rev-parse --abbrev-ref HEAD))


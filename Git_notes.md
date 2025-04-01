## Add Git auto-complete

Download the autocomplete file with `curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash` and add the code below to your `~/.bash_profile` file
```bash
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
```

You may need reload `.bash_profile` by running `source ~/.bash_profile` especially if using vscode remote which keeps a node process open.

## Set Email and Username
```bash
git config --global user.name "stratusjerry"
git config --global user.email "stratusjerry@users.noreply.github.com"
git config --local user.name "stratusjerry"
git config --local user.email "stratusjerry@users.noreply.github.com"
git config --global --unset user.email
git config --global init.defaultBranch main
```

## Signing a commit using GPG and SSH keys
```bash
git config gpg.format ssh
git config commit.gpgSign true
# Use the first key in the SSH agent, versus defining a public key path or literal public key string
git config gpg.ssh.defaultKeyCommand "ssh-add -L"
```

## Various Utility Commands
```bash
# List all git branches
git branch -a
# List all tags
git tag -l -n
# Find the commit when a line of text in a file matches a string
cd git/bitnami/charts/bitnami/kafka
git log -S "appVersion: 3.4" -- Chart.yaml  # Show's when the "appVersion" contained "3.4"
git log -G "^version: 14\." -- Chart.yaml  # Regex search when the "version" contained "14."
# View the log of a different local branch
git log discovery
# View changes made by a commit
git show 74a577e912868d6435ff3c178d8f6b33a37967bf
# Stash untracked files
git stash --include-untracked
# Remove local 'remote-tracking' branches no longer on remote
git remote prune origin --dry-run
git remote prune upstream --dry-run
#git fetch origin --prune --prune-tags --dry-run
# Git does NOT offer a nice option of pruning local branches that do not exist on
#   local 'remote-tracking' OR remote branches, so we have this option
for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do echo Deleting local branch $branch; done
#for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $branch; done
# Below is imperfect, potential false positive if commit contains ': gone]', but is useful if above method is not working
for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do echo Deleting local branch $branch; done
#for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
# Sometimes (seems to be older git versions like our CentOS 7 git hack) the above orphaned local branch
#   cleanup doesn't work. The "./.git/config" file still has a reference to "merge = refs/heads/foobar".
#   Let's try doing a checkout local orphan/remove upstream to then get the "gone" branch
git branch -avv  # Find our orphaned local
git checkout backup-dev-k3s-k3d 
git branch --unset-upstream
# at this point 'gone' doesn't show up but the branch is missing a '[]' origin reference

# Change HEAD to main, needed on local after remote default moved from master to main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
# Find large files in git history
git rev-list --objects --all |
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
  sed -n 's/^blob //p' |
  sort --numeric-sort --key=2 |
  cut -c 1-12,41- |
  $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
```

## Git diff and patching
See [patch documentation](./Patch.md) on applying a `.patch` file.

To diff 2 tags on a github repo, you can use the URL syntax like `https://github.com/saltstack/salt/compare/v3006.4...v3006.5` and additional append `.diff` to the URL to generate a diff/patch file like `https://github.com/saltstack/salt/compare/v3006.4...v3006.5.diff`.

```bash
# Download a .diff file between 2 github tags
wget -q "https://github.com/saltstack/salt/compare/v3006.4...v3006.5.diff" -O "./v3006.4_3006.5.diff"
sudo yum install patchutils
# Generate a modified diff file, filtering files changed in directories tests|pkg|.github|tools|requirements|doc
filterdiff -x "*/tests/*" -x "*/pkg/*" -x "*/\.github/*" -x "*/tools/*" -x "*/requirements/*" -x "*/doc/*" v3006.4_3006.5.diff > v3006.4_3006.5_no_tests_pkg_github_tools_requirements_doc.diff
# Generate a modified diff file, only including files changed in salt directory
filterdiff -i "*/salt/*" v3006.4_3006.5.diff > v3006.4_3006.5_salt_dir_only.diff
# Only include salt directory changes and CLEAN
filterdiff --clean -i "*/salt/*" v3006.4_3006.5.diff > v3006.4_3006.5_salt_dir_only_CLEAN.diff
## Note: filtering above seems to be wildcard and not regex because we can't combine a bunch of the regex filter with "|" OR operator, may require Extended regex "groups"
##   filterdiff "--clean" flag removes non diff lines (comments)
# Get just the file changes from branch "documentation_updates" into local master (not the commits) by using patch
git checkout documentation_updates
git pull
git diff origin/master > changes.patch
git checkout master
git apply < changes.patch
#    now you can add/commit
```

Git diff files between 2 separate commits and ignore whitespace changes
```bash
git diff -w 1b1d111111e766a11d11015ef111c111f97de8f7:charts/vendors/opensearch-0.4.1/README.md b03ae11111d98d11bafe362c11111111c178a8d1:charts/vendors/opensearch-1.0.2/README.md
```

Amend a Git commit to a previous date (only works on current commit unless rebasing)
```bash
git commit --amend --no-edit --date="3 days ago"
#git commit --amend --no-edit --date="2024-07-10T14:00:00"
#git push --force-with-lease
```

## Releases and tagging
? When creating a Gitlab release, what should the tag message be? If left blank, a lightweight tag is created.

## Moving to Git LFS, re-writing all branch/tag history
```bash
# Run a report
git lfs migrate info --everything
# Move files in data directory, ending in .json to LFS
git lfs migrate import --everything --include="data/*.json"
# Force push update all branches AND tags
git push --force --all
git push --force --tags
```

## Fix local tags different than remote error
```bash
# Fix for vscode git sync error "would clobber existing tag"
git fetch --tags --force  #TODO investigate --prune-tags
```

## Rebase a local branch with changed/rebased remote (origin) branch
```bash
git pull --rebase
```

## Change the order of commits in a branch
```bash
# Interactively change the order of commits in branch "foo", which is 3 commits ahead of main
#  Set vscode as git editor for pretty rebasing
#  git config --global core.editor "code --wait"
git checkout foo
git rebase -i main
# Make changes here
# force push to origin/foo
git push --force
```

## Duplicate (copy) a file, preserving git line history
```bash
# Create a branch to be used for creating new file via a rename of the original file; then restore the original file.
git checkout -b dup
git mv filename filename-new
git commit --author="stratusjerry <stratusjerry@users.noreply.github.com>" -m "duplicate filename to filename-new"
git checkout HEAD~ filename # Restores the file from previous commit state
git commit --author="stratusjerry <stratusjerry@users.noreply.github.com>" -m "restore filename"
git checkout - # Checkout the master/main branch
git merge --no-ff dup
# dup branch deleted the filename file, then restored it. Meaning no net change to the file in the dup branch, git log won’t notice it by default
#  If you do git diagnostics of the filename file, the merge doesn’t even show up
git log --oneline filename
git blame filename
git blame filename-new
git push
```

## Create new branch locally and push
```bash
git fetch upstream
git checkout -b newbranch upstream/newbranch
git push -u origin newbranch
```

## Rebase a forked main branch with upstream
```bash
git remote add upstream git@gitlab.com:foo/bar.git
git fetch upstream
git checkout main
git rebase upstream/main
# In Gitlab Setting -> Repository -> Protected branches, allow force push
git push origin main #--force
```

## Undo last commit pushed to remote branch
```bash
# Revert local to prior commit, leaving changes
git checkout somefeaturebranch
git reset --soft HEAD^ #might need to unstage or 'reset --force'
git push --force
```

## Reset a branch to main
```bash
git pull # In case origin/main is different
git checkout somebranch
# Keep local changed files/commits
git reset --soft main
# Undo a git reset (if files changed) git reset 'HEAD@{1}'
# Don't keep local changed files/commits
git reset --hard main
git push --force
```

## Rebase a CHANGED fork "main" branch with upstream
```bash
git remote add upstream git@gitlab.com:foo/bar.git
git fetch upstream
git checkout main
git reset --hard upstream/main
# In Gitlab Setting -> Repository, allow force push
git push origin main --force
```

## Revert a file(s) from a specific commit
```bash
git checkout c5f511 -- file1/to/restore file2/to/restore
git checkout 8cc111e1 -- foo/bar/file1 foo/bar/file2 foo/bar/file3
git checkout d7111a51 -- foo/file1 foo/file2
# Optionally, use "cherry-pick -n" to stage files from a commit but not "commit" them
git cherry-pick -n "1d9ea111fe1111e56d4f4f7a44d7b8211111111"
```

## Rebase a branch with main
```bash
# Create a backup branch to test rebasing "test-rebase"
git pull
git checkout test-rebase
git rebase origin/main
git push origin test-rebase --force
```

## Add branches from main repo into fork
```bash
git remote add upstream git@gitlab.com:foo/bar.git
git fetch upstream
git branch -r --list "upstream/*" # Get the name of the branch to mirror
git checkout -b "feature-branch" "upstream/feature-branch" # Create local branch with contents of upstream branch
# Option 1: push and update tracking in one line (Use this!)
git push -u origin "feature-branch" # -u updates the tracking branch from upstream to origin
# Option 2: update local tracking branch to origin, then push to origin
## Partially errors, git let's us set remote but not "merge = refs/heads/feature-branch" (even with --force)
## because the remote branch doesn't exist yet
git branch -u origin "feature-branch"
git push -u origin "feature-branch"
```

## Create a new branch locally and push to remote
```bash
# Assuming you're on the branch you want to create a branch from (check git status)
git checkout -b somenewbranch
# Push somenewbranch to origin, setting upstream
push -u origin somenewbranch
```

## Remove old remote branches
There's probably a real ugly multiline sed way to do this but here's a partially manual
```bash
# List all remote branches sorted by oldest date and dump to a file
git branch -r --sort=committerdate > old_branches.txt
# Edit the list into a single space delimited of branches to delete (remove newline, remove "  origin/", etc) and delete git remote branch
git push origin --dry-run --delete 7-11-stable-ee 7-12-stable-ee 7-13-stable-ee 7-14-stable-ee 8-0-stable-ee 8-1-stable-ee
```

## Find Git files older than a certain date
```bash
date="2022-05-01"
git ls-files | while read path
do
  if [ "$(git log --since \"$date\" -- $path)" == "" ]
  then
    echo "$path $(git log -1 --pretty='%as' -- $path)"
  fi
done
```

## Building newer Git on CentOS 7
```bash
sudo yum -y groupinstall "Development Tools"
sudo yum -y install gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel
cd /data
git clone https://github.com/git/git.git  #git@github.com:git/git.git
cd git
git checkout v2.32.0  # Specify git version
make configure
./configure --prefix=/usr/local
sudo make install
/usr/local/bin/git --version
sudo yum remove git
#sudo yum remove git-*
```

## Create a tag with cherry picked commits
```bash
# Create a new branch with the original tag contents and check it out
git branch onedotone 1.0
git checkout onedotone
# Add the cherry picked commits to the new branch
git cherry-pick 1d1111b6f1ef9af1111f11f1e111b149f0bf1b92
# Create the new tag with the cherry picked commits
git tag 1.1
# Only push the new tag to remote (doesn't push local branch)
git push origin 1.1
```
Alternatively, the above can be modified for use cases like updating a tag like:
```bash
# Create a new branch with the original tag contents and check it out
git branch onedotupdated 1.0
# Add the cherry picked commits to the new branch
git checkout onedotupdated
git cherry-pick 1d1111b6f1ef9af1111f11f1e111b149f0bf1b92
# Delete the original tag
git tag -d 1.0
# Create the new tag based on the new cherry picked commit
git tag 1.0
# Delete the original remote tag
git push origin :1.0
# Push new tag and commits
git push origin 1.0
```

## Debugging issues on Windows workspace

### "git clone" getting "Permission denied" using Pageant
Might need to modify Git Environment Variables
```powershell
# show set environment variables
set p
# set environment variable, NOTE: Double quoting path actually makes git clone fail
set GIT_SSH=C:\Program Files\PuTTY\plink.exe
# Run plink host to add key when prompted. TODO: there's probably a flag to accept key
plink git@gitlab.com
# Clone Should now work
git clone git@gitlab.com:stratusjerry/gitlab.git
## Other Notes:
##   'GIT_SSH_COMMAND' variable takes precedence in newer Git version
##   'setx' may be used to persist environment variables
```

## Git Lines of Code metrics

```bash
# Get a variety of stats on an authors modified lines in a branch
git log --author="stratusjerry" --pretty=tformat: --numstat \
| gawk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }' -
```

## Secrets in Git (`git-crypt`, `SOPS`)
git-crypt : only uses GPG keys


## Forking an old repository version (wip)
We want to create a fork of the [terraform-aws-dynamodb-table](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table) repo that supports the version of Terraform AWS Provider we are using (`4.9.0`) and only keep the most recent commit and tags that support that version. The repo contains 1 branch (`master`) which makes this easier

> Notes: the AWS provider version level goes from `4.59` in tag `v3.3.0` to `5.21` in tag `v4.0.0`, commit [d596c253d91c7b44b35f62c520f724d86a2bef23](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table/commit/d596c253d91c7b44b35f62c520f724d86a2bef23)

```bash
# Clone the current repo

# Get the hash of the latest commit that supports the version we need and reset to it

# Remove tags newer than the version we want

# Add our fork as a remote origin and push

```

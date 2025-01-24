How to create a *.patch* file for patching software

If the patch is a git commit, get the commit URL like https://github.com/saltstack/salt/commit/ff3397abd719d7efcb2c669020c04fa78513dc75 and add `.patch` to the end, like https://github.com/saltstack/salt/commit/ff3397abd719d7efcb2c669020c04fa78513dc75.patch

Install the patch utility
```bash
sudo yum install -y patch
## Call the patch utility with the name of the file
sudo patch /dir/to/patchfile -b /dir/to/file.patch
```

## differing folder structure
If the .patch file specifies file in a directory structure, it can be overriden with the `patch` flag `-p1` where the ending number strips the directory level of the file. The `-d` flag tells patch to change directory. Additional debugging flags include `--ignore-whitespace`

Notes on Ansible

## Roles Ordering
Roles folder files (example `./roles/selinux/`) are loaded in the order:
1. `defaults/main.yml` (for default vars)
1. `vars/main.yml` (for static vars)
1. `meta/main.yml` (if any role dependencies)
1. `tasks/main.yml` (to execute tasks)

# Ansible Cheat Sheet (lab edition)

## Ad-hoc command syntax
```
ansible <pattern> -m <module> -a "<arguments>" [options]
```

| Goal | Command |
|---|---|
| Ping all nodes (password auth) | `ansible all -m ping -k` |
| Ping all nodes (key auth) | `ansible all -m ping` |
| Run a shell command | `ansible webservers -m ansible.builtin.command -a "uptime"` |
| Pipes / redirects need `shell` | `ansible all -m ansible.builtin.shell -a "df -h \| grep /"` |
| Install a package (root) | `ansible webservers -b -m ansible.builtin.apt -a "name=tree state=present update_cache=true"` |
| Copy a file | `ansible all -b -m ansible.builtin.copy -a "content='hello' dest=/tmp/hello.txt"` |
| Create a user | `ansible dbservers -b -m ansible.builtin.user -a "name=carol state=present"` |
| Restart a service | `ansible webservers -b -m ansible.builtin.service -a "name=nginx state=restarted"` |
| Gather facts | `ansible web1 -m ansible.builtin.setup -a "filter=ansible_distribution*"` |
| One host only | `ansible web1 -m ping` |
| Several groups | `ansible 'webservers:dbservers' -m ping` |

## Useful options
| Option | Meaning |
|---|---|
| `-i FILE` | inventory file |
| `-u USER` | remote user |
| `-k` / `--ask-pass` | prompt for SSH password (needs `sshpass`) |
| `-b` / `--become` | run as root (sudo) |
| `-K` / `--ask-become-pass` | prompt for sudo password |
| `-f N` | forks (parallel hosts) |
| `-v` … `-vvvv` | more verbose output |
| `--limit web1` | run on a subset |

## Playbook commands
```
ansible-playbook playbooks/03_webserver.yml --syntax-check
ansible-playbook playbooks/03_webserver.yml --check --diff     # dry run + show changes
ansible-playbook playbooks/03_webserver.yml --limit web1
ansible-playbook playbooks/site.yml --tags motd
ansible-playbook playbooks/site.yml --list-tasks
ansible-playbook playbooks/07_vault.yml --ask-vault-pass
```

## Inventory and docs
```
ansible-inventory --graph
ansible-inventory --host web1
ansible-doc -l | grep apt
ansible-doc ansible.builtin.copy
ansible-doc -s ansible.builtin.user     # short snippet
ansible-config dump --only-changed
```

## Vault
```
ansible-vault create  vault/secrets.yml
ansible-vault encrypt vault/secrets.yml
ansible-vault view    vault/secrets.yml
ansible-vault edit    vault/secrets.yml
ansible-vault decrypt vault/secrets.yml
```

## Roles
```
ansible-galaxy role init roles/myrole
ansible-galaxy collection install community.general
```

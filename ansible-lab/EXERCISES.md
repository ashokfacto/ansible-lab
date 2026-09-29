# Hands-on Exercises

Work from the lab folder (`cd ~/ansible-lab` in WSL, or `/ansible` in the control container).
Lab login for every node: user `ansible`, password `ansible`.

## Ex 1 - Inventory and first contact (5 min)
1. `ansible-inventory --graph` - see groups and hosts.
2. `ansible all -m ping -k` - type the password `ansible`. Expect green `"ping": "pong"`.
3. Try `ansible webservers -m ping -k` and `ansible web1 -m ping -k`.

## Ex 2 - Authentication: move to SSH keys (5 min)
1. Make sure a key exists: `ls ~/.ssh/id_ed25519.pub` (create with `ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519`).
2. `ansible-playbook playbooks/06_ssh_keys.yml -k`
3. `ansible all -m ping` - works with **no password** now.

## Ex 3 - Ad-hoc commands (10 min)
1. `ansible all -m ansible.builtin.command -a "hostname"`
2. `ansible all -m ansible.builtin.command -a "cat /etc/os-release"`
3. Install `tree` on the web servers: `ansible webservers -b -m ansible.builtin.apt -a "name=tree state=present update_cache=true"`
4. Run step 3 again. Colour changes from yellow (changed) to green (ok) - that is **idempotency**.
5. Find out what the `file` module can do: `ansible-doc -s ansible.builtin.file`

## Ex 4 - Your first playbook (10 min)
1. `ansible-playbook playbooks/02_facts.yml`
2. `ansible-playbook playbooks/03_webserver.yml --check` (dry run)
3. `ansible-playbook playbooks/03_webserver.yml`
4. Open http://localhost:8081 and http://localhost:8082 in your Windows browser.
5. Change `page_title` in `inventory/group_vars/webservers.yml`, run again with `--diff`. Notice the handler runs only because the template changed.

## Ex 5 - Variables, loops, conditionals (5 min)
1. `ansible-playbook playbooks/04_vars_loops_conditions.yml`
2. `ansible-playbook playbooks/05_users.yml` then add a user `carol` to `lab_users` in `group_vars/all.yml` and rerun.

## Ex 6 - Secrets with Vault (5 min)
1. `cp vault/secrets.example.yml vault/secrets.yml`
2. `ansible-vault encrypt vault/secrets.yml` (choose a password), then `cat vault/secrets.yml`
3. `ansible-playbook playbooks/07_vault.yml --ask-vault-pass`
4. Check: `ansible db1 -b -m ansible.builtin.command -a "cat /etc/app-db.conf"`

## Ex 7 - Roles (5 min)
1. `tree roles/` - look at the structure.
2. `ansible-playbook playbooks/site.yml`
3. `ansible-playbook playbooks/site.yml --tags motd`
4. Create your own skeleton: `ansible-galaxy role init roles/demo`

## Stretch goals
- Lint your work: `ansible-lint playbooks/`
- Write a playbook that creates `/opt/app` with mode `0755` on all hosts using `ansible.builtin.file`.
- Add a `when:` so a task runs only on `db1`.

## Reset the lab
`docker compose down && docker compose up -d --build` gives you fresh nodes.
(After a reset, run Ex 2 again - the new containers do not have your key.)

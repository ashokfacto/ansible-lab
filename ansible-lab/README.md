# Ansible for Beginners - Windows Local Lab Setup

> 📖 **Session walkthrough:** the whole beginner course (about 2 hours) is a web page in [`docs/index.html`](docs/index.html). Once GitHub Pages is on it lives at `https://<your-user>.github.io/<repo>/`. See [Publish the walkthrough](#publish-the-walkthrough-on-github-pages).

This lab gives you a **control node** and **three managed Linux nodes** on a Windows laptop, with no cloud account and no VMs to build by hand.

```
 Windows laptop
 ├── WSL2 (Ubuntu 24.04)  ← CONTROL NODE: Ansible is installed here
 │        │  SSH to 127.0.0.1:2221 / 2222 / 2223
 └── Docker Desktop
          ├── web1  (Ubuntu 22.04, SSH 2221, HTTP 8081)
          ├── web2  (Ubuntu 22.04, SSH 2222, HTTP 8082)
          ├── db1   (Ubuntu 22.04, SSH 2223)
          └── control (optional Ansible container - fallback if WSL is not possible)
```

> **Why WSL?** Ansible's control node does not run natively on Windows. Windows machines can be *managed* by Ansible (over WinRM/SSH), but the controller must be Linux/macOS - WSL2 gives you a real Linux on Windows.

---

## 1. Prerequisites

| Item | Requirement |
|---|---|
| OS | Windows 10 22H2 or Windows 11 (64-bit) |
| RAM / disk | 8 GB RAM minimum (16 GB comfortable), 15 GB free disk |
| BIOS | Virtualization (Intel VT-x / AMD-V) enabled |
| Rights | Local administrator (to install WSL and Docker) |
| Network | Internet access (images and packages are downloaded). Corporate proxy? See Troubleshooting |

Quick check - in PowerShell, from the lab folder:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-prereqs.ps1
```

## 2. Install WSL2 + Ubuntu (≈10 min)

Open **PowerShell as Administrator**:
```powershell
wsl --install -d Ubuntu-24.04
```
Reboot when asked. Ubuntu opens and asks for a **new Linux username and password** (remember them - this is your `sudo` password).

Verify (PowerShell):
```powershell
wsl -l -v        # Ubuntu-24.04 must show VERSION 2
```
If it shows version 1: `wsl --set-version Ubuntu-24.04 2`

## 3. Install Docker Desktop (≈10 min)

1. Download and install Docker Desktop for Windows from docker.com. Keep **"Use WSL 2 instead of Hyper-V"** ticked.
2. Start Docker Desktop, then go to **Settings → Resources → WSL integration** and switch on **Ubuntu-24.04**. Apply & restart.
3. In the Ubuntu terminal:
   ```bash
   docker run --rm hello-world
   ```
   If you get *permission denied*, close and reopen the Ubuntu terminal.

## 4. Install VS Code (recommended, ≈5 min)

Install VS Code, then these extensions: **WSL** (Microsoft), **Ansible** (Red Hat), **YAML** (Red Hat).
From Ubuntu you can then run `code .` inside the lab folder to edit files with Ansible syntax help.

## 5. Get the lab into your WSL home folder (important!)

In the Ubuntu terminal, clone the repository straight into your Linux home:
```bash
git clone https://github.com/<your-user>/<repo>.git ~/ansible-lab
cd ~/ansible-lab
```
Got a zip instead? Unzip it in Windows, then `cp -r /mnt/c/Users/<YourWindowsUser>/Downloads/ansible-lab ~/`.
> ⚠️ **Do not work from `/mnt/c/...`.** Windows folders appear *world-writable* inside WSL, and Ansible deliberately **ignores `ansible.cfg`** in world-writable directories (security feature). You'll see *"Ansible is being run in a world writable directory … ignoring it as an ansible.cfg source"* and nothing will work as expected.

## 6. Install Ansible in WSL (≈5 min)

```bash
bash scripts/setup-wsl.sh
source ~/.bashrc
ansible --version
```
The script installs `pipx`, `sshpass`, the full `ansible` package and `ansible-lint`, and creates an SSH key at `~/.ssh/id_ed25519`.

<details><summary>Manual install instead of the script</summary>

```bash
sudo apt update && sudo apt install -y pipx python3-venv sshpass
pipx ensurepath && source ~/.bashrc
pipx install --include-deps ansible
pipx install ansible-lint
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```
</details>

## 7. Start the managed nodes (≈3-5 min first time)

```bash
cd ~/ansible-lab
docker compose up -d --build
docker ps            # web1, web2, db1, control should be "Up"
```

## 8. Smoke test

```bash
ansible-inventory --graph
ansible all -m ping -k        # SSH password: ansible
```
Three green `SUCCESS ... "ping": "pong"` lines = you are ready to start the walkthrough. 🎉

---

## Plan B - no WSL? Use the control container

If WSL cannot be installed (locked-down laptop), everything runs inside Docker:
```powershell
cd C:\path\to\ansible-lab
docker compose up -d --build
docker compose exec control bash
```
Inside the container:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
ansible all -m ping -k        # password: ansible
```
The container already has Ansible, ansible-lint and sshpass, and uses `inventory/lab.ini` automatically. The lab folder is mounted at `/ansible`, so edit files in Windows with VS Code and run them in the container.

---

## Lab reference

| Item | Value |
|---|---|
| SSH user / password on nodes | `ansible` / `ansible` (passwordless sudo) |
| WSL inventory | `inventory/wsl.ini` (default via `ansible.cfg`) |
| Container inventory | `inventory/lab.ini` |
| Web pages | http://localhost:8081 (web1), http://localhost:8082 (web2) |
| Reset everything | `docker compose down && docker compose up -d --build` |
| Stop at end of day | `docker compose stop` |

### What's in the folder
```
ansible-lab/
├── docs/index.html             the 2-hour walkthrough page (GitHub Pages)
├── ansible.cfg                 project configuration
├── docker-compose.yml          the lab machines
├── node/Dockerfile             managed-node image (Ubuntu + sshd + python3)
├── control/Dockerfile          optional control-node image
├── inventory/
│   ├── wsl.ini  lab.ini  lab.yml
│   ├── group_vars/  all.yml  webservers.yml
│   └── host_vars/   db1.yml
├── playbooks/
│   ├── 01_ping.yml                    connectivity
│   ├── 02_facts.yml                   facts
│   ├── 03_webserver.yml               full play: install, template, service, handler
│   ├── 04_vars_loops_conditions.yml   vars, loop, when, register
│   ├── 05_users.yml                   users from group_vars
│   ├── 06_ssh_keys.yml                authentication: password -> SSH keys
│   ├── 07_vault.yml                   Ansible Vault secrets
│   ├── site.yml                       roles
│   └── templates/index.html.j2
├── roles/  common/  nginx/
├── vault/secrets.example.yml
├── scripts/ setup-wsl.sh  check-prereqs.ps1
├── CHEATSHEET.md
└── EXERCISES.md
```

---

## Publish the walkthrough on GitHub Pages

1. Push this folder to a new GitHub repository (for example `ansible-lab`):
   ```bash
   git init && git add . && git commit -m "Ansible beginner lab"
   git branch -M main
   git remote add origin https://github.com/<your-user>/ansible-lab.git
   git push -u origin main
   ```
2. On GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**, branch `main`, folder **`/docs`**, then **Save**.
3. After a minute the page is live at `https://<your-user>.github.io/ansible-lab/`.

The page detects the repository from its own address, so the file links and the `git clone` command in it point at your repo automatically. `docs/.nojekyll` stops GitHub from processing the `{{ }}` Jinja examples.

**Presenting from the page:** press **P** for present mode (bigger text, no sidebar) and use **← →** to move between sections. The sidebar timer shows where you should be in the agenda, and **Trainer notes → Show** reveals speaker notes (or open the page with `?notes`). Participants can use the same link to follow along and copy commands.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `ansible: command not found` | `source ~/.bashrc` or open a new terminal (pipx adds `~/.local/bin` to PATH) |
| *"world writable directory … ignoring ansible.cfg"* | You are in `/mnt/c/...`. Copy the lab to `~` (step 5) |
| `to use the 'ssh' connection type with passwords … you must install the sshpass program` | `sudo apt install -y sshpass` |
| `UNREACHABLE … Connection refused` | Containers not running: `docker compose up -d`; check `docker ps` |
| `docker: command not found` in WSL | Docker Desktop → Settings → Resources → WSL integration → enable Ubuntu |
| `Permission denied (publickey,password)` | Use `-k` and password `ansible`, or rerun `06_ssh_keys.yml -k` after a lab reset |
| `wsl --install` error 0x80370102 | Enable virtualization in BIOS; enable "Virtual Machine Platform" Windows feature |
| apt/pip/docker downloads fail on office network | Set proxy: Docker Desktop → Settings → Resources → Proxies; in WSL `export https_proxy=http://proxy:port` |
| Port 2221/8081 already in use | Change the left side of the port mapping in `docker-compose.yml` and in `inventory/wsl.ini` |
| nginx page not loading | `ansible webservers -b -m ansible.builtin.service -a "name=nginx state=started"` |

---

## Teaching this as a class? Instructor checklist

- [ ] Send this guide + `ansible-lab.zip` to participants 2-3 days before the session and ask for a screenshot of step 8.
- [ ] Run the full lab once on a clean laptop the day before.
- [ ] Have the Plan B control container ready for anyone whose WSL install fails.
- [ ] Keep `docker compose down && up -d --build` handy to reset broken labs quickly.
- [ ] Pre-open: the slide deck, a WSL terminal in `~/ansible-lab`, VS Code, and a browser on localhost:8081.

# Arch / Artix Setup

Declarative Arch / Artix Linux installation using Ansible.

Clean. Reproducible. Minimal.

---

# Overview

This project replaces shell-based install scripts with structured, idempotent Ansible roles.

It performs a full system installation in **two chronological stages**:

1. Bootstrap (from live ISO)
2. System configuration (after reboot)

Supports:

- Arch (systemd)
- Artix (OpenRC)
- KDE Plasma (minimal)

---

## Features

- **Openrc** as init with **artix**
- **SystemD** as init with **arch**
- **Secure Boot**
- **Zen** kernel
- **Zstd** Compression
- **Btrfs**
- **Zram**
- **LUKS** encryption
- **Apparmor**
- **Dnscrypt**
- **Some tweaks for performance**
- **Hardened SSH**
- **Hardened Firewall**
- **Hardened browser** with custom settings and user policy

## How to Install

**Base install**

> Connect to internet before running the below commands and edit the `inventory/base.yaml` as per your needs

```sh

git clone https://github.com/glowfi/setup
ansible-playbook -i inventory/base.yaml playbooks/base.yaml
```

**DE/WM/Server install**

> Restart and login as the new user created from above script and run the below commands. Edit the `inventory/system.yaml` as per your needs.

```sh
cd
git clone https://github.com/glowfi/setup
ansible-playbook -K -i inventory/system.yaml playbooks/system.yaml
```

---

# Structure

```
roles/
├── 1_disk
├── 2_pacstrap
├── 3_base
├── 4_system
└── common
```

Each role handles one layer of the system.

Execution is sequential and predictable.

---

# Philosophy

- Idempotent
- Declarative
- Minimal
- No interactive prompts
- No fragile shell chains
- Re-runnable at any time

If something breaks, fix the role and rerun.

---

# Requirements

- Basic understanding of Arch
- Comfort reading logs
- Willingness to manage your own system

---

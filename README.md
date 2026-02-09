# Arch / Artix Setup (Ansible)

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

# Stage 0 — Boot ISO

Boot into:

- Arch Linux ISO  
  or
- Artix Linux ISO

Connect to the internet first.

---

# Stage 1 — Bootstrap (Disk + Base System)

This stage:

- Partitions disk
- Sets up LUKS encryption
- Creates Btrfs layout with subvolumes
- Enables Zstd compression
- Installs base system
- Installs Zen kernel
- Configures bootloader
- Enables Secure Boot (if configured)
- Prepares system for first reboot

Run:

```bash
pacman -Sy git ansible
git clone https://github.com/glowfi/setup
cd setup
ansible-playbook -i inventory/bootstrap.yaml playbooks/base.yaml
```

After completion:

```bash
reboot
```

---

# Stage 2 — System Installation

Login as the newly created user.

This stage:

- Configures pacman
- Installs KDE (minimal)
- Configures SDDM
- Sets up NetworkManager
- Installs PipeWire audio
- Installs development stack (Node, Rust, Go, Python)
- Configures virtualization (libvirt + QEMU)
- Installs and configures browsers
- Enables AppArmor
- Configures dnscrypt-proxy
- Sets up nftables firewall
- Enables ZRAM
- Applies performance tuning
- Deploys dotfiles
- Hardens SSH

Run:

```bash
git clone https://github.com/glowfi/setup
cd setup
ansible-playbook -i inventory/system.yaml playbooks/base.yaml
```

Reboot once finished.

---

# Inventory Configuration

Edit:

```
inventory/system.yaml
```

Example:

```yaml
all:
    vars:
        os: arch # arch | artix
        de_wm: kde
    hosts:
        pc:
            ansible_host: 192.168.1.10
            ansible_user: username
```

---

# What Gets Installed

## Core

- Zen kernel
- LUKS
- Btrfs
- ZRAM
- AppArmor
- dnscrypt-proxy
- nftables
- Hardened SSH

## Desktop

- plasma-desktop
- plasma-workspace
- breeze
- SDDM
- Dolphin, Okular, Gwenview
- PipeWire

Configured with:

- Splash disabled
- Launch feedback disabled
- Baloo disabled
- KWallet disabled
- Theme set to Breeze Dark

## Dev Stack

- Node (manual install)
- Rust (rustup)
- Go (local install)
- Python (user-based pip)
- Neovim + LSP tooling

## Virtualization

- libvirt
- qemu
- virt-manager
- DNS + bridge setup

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

<div align="center">

# ⚙️ setup

Declarative **Arch / Artix Linux** installation using **Ansible**

Clean • Reproducible • Minimal

![Arch](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)
![Artix](https://img.shields.io/badge/Artix-10A0CC)
![Automation](https://img.shields.io/badge/Automation-Ansible-red?logo=ansible&logoColor=white)
![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)

</div>

---

## ✨ What is this?

A fully declarative installation framework for **Arch** and **Artix** Linux.

Instead of fragile install scripts, the system is described using
**idempotent Ansible roles** — allowing installs to be:

- reproducible
- auditable
- re-runnable
- predictable

> Fix configuration → rerun playbook.

---

## 🧠 Installation Model

The system installs in **two deterministic stages**:

```

Live ISO
│
├─ 1️⃣ Bootstrap
│     Disk → Base system → Users
│
└─ 2️⃣ System Configuration
Desktop → Services → Hardening

```

### Supported

| Distribution | Init    |
| ------------ | ------- |
| Arch Linux   | systemd |
| Artix Linux  | OpenRC  |

Desktop target: **Minimal KDE Plasma**

---

## 🚀 Features

### System

- 🔐 Secure Boot support
- 💾 LUKS full disk encryption
- 🗜️ Btrfs + Zstd compression
- ⚡ ZRAM memory optimization
- 🧠 Zen / Hardened kernel support

### Security

- 🛡️ AppArmor enabled
- 🔒 Hardened SSH configuration
- 🔥 Firewall hardening
- 🌐 dnscrypt-proxy
- 🌍 Hardened browser policies

### Philosophy

- Idempotent execution
- Declarative configuration
- Minimal defaults
- No interactive prompts
- Safe re-execution anytime

---

## ⚡ Quick Start

### 1️⃣ Base Install (Live ISO)

Edit:

```sh
inventory/base.yaml
```

Then run:

```sh
git clone https://github.com/glowfi/setup
cd setup

ansible-playbook \
  -i inventory/base.yaml \
  playbooks/base.yaml \
  --ask-vault-pass
```

> 💡 Installing remotely? Enable SSH first.

---

### 2️⃣ System Setup (After Reboot)

Login as the created user.

Edit:

```sh
inventory/system.yaml
```

Run:

```bash
git clone https://github.com/glowfi/setup
cd setup

ansible-playbook -K \
  -i inventory/system.yaml \
  playbooks/system.yaml
```

---

## 🗂️ Repository Structure

```
roles/
├── 1_disk        → partitioning & encryption
├── 2_pacstrap    → base system bootstrap
├── 3_base        → core configuration
├── 4_system      → desktop & services
└── common        → shared logic
```

Each role represents a **single system layer**.

Execution order is explicit and chronological.

---

## 🔁 Idempotency

All tasks are designed to be safely re-run.

```
change config
      ↓
rerun playbook
      ↓
system converges to desired state
```

No reinstall required.

---

## 🔐 Secrets

Sensitive values are protected using **Ansible Vault**.

Run playbooks with:

```bash
--ask-vault-pass
```

Encrypted values are safe to store in Git.

---

## 📋 Requirements

- Basic Arch Linux knowledge
- Ability to read logs
- Comfort debugging system configuration

This project does **not** abstract Linux away — it makes it reproducible.

---

## 🤝 Contributing

Issues, improvements, and ideas are welcome.

Small, focused PRs preferred.

---

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

See the [LICENSE](LICENSE) file for details.

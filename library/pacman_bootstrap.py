#!/usr/bin/python
# pylint: disable=missing-module-docstring, line-too-long

# Copyright: (c) 2023, Dominik Liebich
# GNU Affero General Public License v3.0+ (see LICENSES/AGPL-3.0-or-later.txt or https://www.gnu.org/licenses/agpl-3.0.txt)
from __future__ import absolute_import, division, print_function

from subprocess import run
from pathlib import Path
from shutil import which

from ansible.module_utils.basic import AnsibleModule, shlex

# pylint: disable-next=invalid-name
__metaclass__ = type

DOCUMENTATION = r"""
---
module: pacman_bootstrap
short_description: Installs or removes packages via pacman

description:
    - Installs or removes packages via pacman.
    - Will be used by all roles which might run during bootstrapping,
      i.e. when the Arch Linux Live System is mounting the system
      drive under '/mnt'.
    - In these roles it replaces 'community.general.pacman'
    - Please use 'community.general.pacman' instead in all roles
      not used during bootstrap.

options:
    name:
        description:
          - List of packages to install or remove
        required: true
        type: list
    state:
        description:
          - "present" to install package
          - "absent" to remove package
        required: false
        type: str
    force:
        description:
          - When removing packages, forcefully remove them, without any checks.
    update_cache:
        description:
          - Whether or not to refresh the master package lists.
    chroot_mountpoint:
        description:
          - Mountpoint of chroot environment (during bootstrap)
          - empty or '/' otherwise
        required: true
        type: str

author:
    - Dominik Liebich (@dliebich)
"""

EXAMPLES = r"""
- name: Install nftables
  pacman_bootstrap:
    name:
      - nftables
      - iptables-nft
    state: present
    update_cache: yes
    chroot_mountpoint: /mnt

- name: Remove iptables
  pacman_bootstrap:
    name: iptables
    state: absent
    force: yes
    chroot_mountpoint: /mnt
"""

RETURN = r"""
installed:
    description:
      - List of installed packages.
    type: str
    returned: changed
removed:
    description:
      - List of removed packages.
    type: str
    returned: changed
stdout:
    description:
      - Output from pacman
    type: str
    returned: failed
stderr:
    description:
      - Errors from pacman
    type: str
    returned: failed
rc:
    description:
      - Return code of pacman
    type: int
    returned: failed
    sample: 1
"""


# pylint: disable-next=missing-class-docstring
class Pacman:
    NOOP = (-1, "nothing to do", "", "")

    # pylint: disable-next=missing-function-docstring
    def __init__(
        self, packages: set, force: bool, update_cache: bool, chroot_mnt: str
    ) -> None:
        if chroot_mnt:
            if which("arch-chroot"):
                self.chroot = ["arch-chroot", chroot_mnt]
            else:
                self.chroot = ["chroot", chroot_mnt]
        else:
            self.chroot = []

        self.packages = packages
        self.force = force
        self.update_cache = update_cache

        self.build_inventory(self.packages)

    def run_command(self, cmd: str) -> tuple[int, str, str]:
        args = shlex.split(cmd, posix=True)
        process = run(
            self.chroot + args,
            capture_output=True,
            check=False,
            text=True,
        )
        return process.returncode, process.stdout, process.stderr

    # pylint: disable-next=missing-function-docstring
    def build_inventory(self, candidates: set) -> None:
        process = run(
            self.chroot + ["pacman", "-Qq"], capture_output=True, check=False, text=True
        )

        self.inventory = set(process.stdout.split())
        self.install_candidates = candidates - self.inventory
        self.remove_candidates = candidates - self.install_candidates

    # pylint: disable-next=missing-function-docstring
    def pacman(self, action: str, candidates: set) -> tuple[int, str, str, str]:
        needed = ["--needed"] if action.startswith("-S") else []
        process = run(
            self.chroot
            + ["pacman", action, "--noconfirm", "--noprogressbar"]
            + needed
            + list(candidates),
            capture_output=True,
            check=False,
            text=True,
        )

        rc = process.returncode
        stdout = process.stdout
        stderr = process.stderr
        changed = " ".join(candidates)

        return rc, stdout, stderr, changed

    # pylint: disable-next=missing-function-docstring
    def installed(self) -> None:
        return set(self.packages) <= set(self.inventory)

    # pylint: disable-next=missing-function-docstring
    def install(self) -> tuple[int, str, str, str]:
        if self.installed():
            return self.NOOP

        suffix = "yy" if self.update_cache else ""
        return self.pacman("-S" + suffix, self.install_candidates)

    # pylint: disable-next=missing-function-docstring
    def remove(self) -> tuple[int, str, str, str]:
        if not self.installed():
            return self.NOOP

        suffix = "dd" if self.force else ""
        return self.pacman("-R" + suffix, self.remove_candidates)


# pylint: disable-next=missing-function-docstring
def run_module():
    module_args = {
        "name": {"type": "list", "required": False},
        "state": {"type": "str", "required": False, "default": "present"},
        "force": {"type": "bool", "required": False, "default": False},
        "update_cache": {"type": "bool", "required": False, "default": False},
        "chroot_mountpoint": {"type": "str", "required": True},
        "command": {"type": "str", "required": False},
        "creates": {"type": "str", "required": False},
        "removes": {"type": "str", "required": False},
    }

    result = {"changed": False, "installed": "", "removed": ""}

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=False)

    state = module.params["state"]
    if not state in ["present", "absent"]:
        module.fail_json(
            msg=f'Invalid parameter state: "{state}"; must be either "present" or "absent".'
        )

    mnt = module.params["chroot_mountpoint"]

    arch_release = Path(mnt + "/etc/arch-release")
    artix_release = Path(mnt + "/etc/artix-release")

    if not arch_release.is_file() and not artix_release.is_file():
        module.fail_json(msg=f'There is no Arch or Artix Linux environment in "{mnt}".')

    packages = set(module.params["name"] or [])
    force = module.params["force"]
    update_cache = module.params["update_cache"]
    command = module.params["command"]

    pacman = Pacman(packages, force, update_cache, mnt)

    if command:
        creates = module.params["creates"]
        removes = module.params["removes"]

        # idempotency check
        if creates and Path(mnt + creates).exists():
            module.exit_json(changed=False)

        if removes and not Path(mnt + removes).exists():
            module.exit_json(changed=False)

        rc, stdout, stderr = pacman.run_command(command)

        if rc > 0:
            module.fail_json(
                msg=f'Failed to run command "{command}"',
                stdout=stdout,
                stderr=stderr,
                rc=rc,
            )

        module.exit_json(
            changed=True,
            stdout=stdout,
            stderr=stderr,
        )

    rc = -1
    stdout = stderr = ""
    action = ""  # pylint: disable=unused-variable

    if state == "present":
        action = "install"
        rc, stdout, stderr, result["installed"] = pacman.install()

    if state == "absent":
        action = "remove"
        rc, stdout, stderr, result["removed"] = pacman.remove()

    if rc == pacman.NOOP[0]:
        module.exit_json(**result)

    if rc > 0:
        module.fail_json(
            msg='Failed to {action} {", ".join(packages)}',
            stdout=stdout,
            stderr=stderr,
            rc=rc,
        )

    result["changed"] = True
    module.exit_json(**result)


# pylint: disable-next=missing-function-docstring
def main():
    run_module()


if __name__ == "__main__":
    main()

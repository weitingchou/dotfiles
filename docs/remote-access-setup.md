# Remote Access & SSH Hardening Runbook

Checklist for making a headless Mac (e.g. a Mac mini running the non-admin
`agentsandbox` dev account) reachable and secure from other machines — over the
LAN and across networks via Tailscale.

> Machine-specific values (tailnet name/IP, account) are intentionally **not**
> recorded here (public repo). Retrieve them on the box with `tailscale status`.

## Concepts (who owns what)

- **Tailscale** — a machine-level WireGuard VPN. An **admin** installs it; one
  tunnel serves the whole box, shared by every account. Reach the machine at its
  tailnet name and then log in as any user.
- **SSH keys** — **per-account**. Each `~/.ssh/authorized_keys` is private to its
  user, so a key must be installed for *each* account you log in as.
- **SSH hardening** (disabling password auth) — **global** to `sshd`: it affects
  every account at once.

## Sequence

### A. Mac mini (server) — admin, mostly done
- [x] Remote Login (SSH) enabled; `agentsandbox` in the SSH-access group
- [x] Power policy: never sleep + auto-restart — `sudo pmset -a sleep 0 autorestart 1`
- [x] Tailscale installed + connected — `sudo tailscaled install-system-daemon && sudo tailscale up`
- [x] MacBook public key installed for `agentsandbox` and `richchou`
- [ ] **Disable key expiry** for this machine in the Tailscale admin console
      (login.tailscale.com → Machines → `<host>` → Disable key expiry). Important
      for a headless server, else its key expires (~180 days) and it drops off
      the tailnet until re-authenticated locally.

### B. Office Ubuntu — do when on-site
- [ ] Install Tailscale — run `install_ubuntu.sh`, or
      `curl -fsSL https://tailscale.com/install.sh | sh`
- [ ] **If this Ubuntu runs under WSL** (Windows Subsystem for Linux): there's no
      systemd as PID 1, so the `tailscaled` systemd service never starts and
      `sudo tailscaled install-system-daemon` fails. Start the daemon by hand
      first: `sudo tailscaled > /dev/null 2>&1 &`. It doesn't survive a
      `wsl --shutdown`, so re-run it (or enable systemd in `/etc/wsl.conf`).
- [ ] `sudo tailscale up` — sign in with the **same** Tailscale identity as the mini
- [ ] **While password auth is still ON**, copy this machine's key to the mini
      over Tailscale (get `<mini>` from `tailscale status`):
      - `ssh-copy-id agentsandbox@<mini>`
      - `ssh-copy-id richchou@<mini>`  (only if you need admin SSH from the office)
- [ ] Verify key login: `ssh agentsandbox@<mini> 'whoami'` → no password prompt

### C. Hardening — ONLY after every machine you log in from has its key installed
Run on the mini as `richchou`:
```bash
sudo tee /etc/ssh/sshd_config.d/100-keys-only.conf >/dev/null <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
sudo sshd -t && echo "config OK"      # only proceed if it prints config OK
```
Verify (keys still work, passwords refused):
```bash
ssh agentsandbox@<mini> 'echo ok'                      # works (key)
ssh -o PubkeyAuthentication=no agentsandbox@<mini>     # Permission denied (publickey,...)
```
Revert if anything is wrong: `sudo rm /etc/ssh/sshd_config.d/100-keys-only.conf`

## Why this order matters

Disabling password auth is global. Every remote machine (MacBook **and** office
Ubuntu) must already have its key in the mini's `authorized_keys`, or it gets
locked out. Adding keys is easiest while password auth is still on (`ssh-copy-id`).
Local console access on the mini is the safety net if a remote path fails.

## Connecting

- Across networks (Tailscale): `ssh <user>@<mini-tailnet-name>` — find the name/IP
  with `tailscale status` / `tailscale ip -4`.
- On the home LAN: `ssh <user>@<host>.local` (Bonjour) or the LAN IP.

## Optional later hardening

- Bind `sshd` to listen only on the Tailscale interface so SSH isn't exposed on
  the LAN at all.
- Use Tailscale ACLs to restrict which devices may reach the mini's SSH port.

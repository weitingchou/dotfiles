# Claude Code Telegram Plugin Runbook

Steps to drive Claude Code from your phone via Telegram, using the official
`telegram@claude-plugins-official` plugin (built on Claude Code's *channels*
feature). DMs to your bot get pushed into a running Claude Code session; Claude
can reply, react, and send files back.

> Secrets (the bot token, your Telegram user ID) are machine-local and
> intentionally **not** recorded here (public repo). The token lives in
> `~/.claude/channels/telegram/.env`; retrieve your user ID from
> [@userinfobot](https://t.me/userinfobot).

## Concepts (who owns what)

- **Bun** — runtime the plugin's MCP server runs on. Installed once per machine
  by the admin platform script (`scripts/install_macos.sh` runs `brew install
  bun`), so it's shared via `/opt/homebrew` like the rest of the toolchain. Only
  install it by hand (`brew install bun`) if you're on a box that predates this.
- **BotFather** — Telegram's bot registrar. Creating a bot yields a **token**;
  whoever holds it controls the bot.
- **Plugin + channel** — the plugin is installed per Claude Code user; the
  channel is activated per session by launching with `--channels`.
- **Access policy** — `pairing` (anyone with a fresh code can attach) vs.
  `allowlist` (only enumerated user IDs). Lock to `allowlist` once paired.

## Prerequisites

- [x] **Bun** — installed by `scripts/install_macos.sh` (macOS); `brew install
      bun` by hand only on older boxes. Verify: `bun --version`.

## Sequence

### A. Create the bot (Telegram app)
- [ ] DM [@BotFather](https://t.me/BotFather) → send `/newbot`
- [ ] Give it a **name** (display, may contain spaces) and a **username** ending
      in `bot` (e.g. `my_assistant_bot`)
- [ ] Copy the token BotFather returns — `123456789:AAHfiqksKZ8...`, including the
      leading number and colon

### B. Install the plugin (inside a Claude Code session)
```
/plugin install telegram@claude-plugins-official
/reload-plugins
```

### C. Configure the token
```
/telegram:configure 123456789:AAHfiqksKZ8...
```
Writes `TELEGRAM_BOT_TOKEN=...` to `~/.claude/channels/telegram/.env`.
Alternative: set `TELEGRAM_BOT_TOKEN` in your shell before launching Claude Code
(the shell env takes precedence over the `.env` file).

### D. Relaunch with the channel enabled
Exit the session, then start with:
```
claude --channels plugin:telegram@claude-plugins-official
```
(The repo's `claude` alias already carries the `KUBECONFIG`/telemetry env, so
this works as-is.) The plugin begins polling your bot for messages.

### E. Pair your phone
- [ ] DM your bot → it replies with a 6-character pairing code
- [ ] In Claude Code: `/telegram:access pair <code>`
- [ ] Your next DM reaches Claude

### F. Lock down access — do once paired
```
/telegram:access policy allowlist
```
Switches from open `pairing` to an `allowlist` so only enumerated user IDs can
drive the session. Get your numeric ID from [@userinfobot](https://t.me/userinfobot).
See the plugin's `ACCESS.md` for the `access.json` schema, group setups, and
mention detection.

## What Claude can do over Telegram

| Tool | Purpose |
|------|---------|
| `reply` | Send text/files to the chat. `reply_to` threads a message; `files` attaches up to 50MB (images auto-preview, others as documents). Long text auto-chunks. |
| `react` | Add an emoji reaction (Telegram's fixed whitelist only: 👍 👎 ❤ 🔥 👀 …). |
| `edit_message` | Edit a message the bot previously sent. |

Other behavior:
- Auto typing indicator while Claude processes.
- Photos you send are saved to `~/.claude/channels/telegram/inbox/`.
- **Live messages only** — the bot has no history/search; it sees nothing sent
  before it was online.
- Multi-bot: point `TELEGRAM_STATE_DIR` at different directories per bot — see
  **One bot per project** below for the full recipe.

## Terminal + Telegram on one session

Launching with `--channels` doesn't create a separate Telegram session — it adds
Telegram as an extra **input/output surface** on the one running `claude`
process. The terminal you launched from and the bot are two windows onto the
*same* live session, with the same context. Consequences worth understanding:

- **Same session, two surfaces.** Type in the terminal *or* DM the bot — both
  drive the same Claude. An incoming DM is injected into the running session, so
  it also appears in the terminal.
- **The session lives in the process, not the phone.** It runs on whatever
  machine you launched it on; Telegram is a remote control. If the process stops,
  the bot has nothing to talk to. To bridge "out → home", keep the process alive
  on an always-on box (run it in `tmux` on the Mac mini), drive it from Telegram
  while out, then Tailscale-SSH home and `tmux attach` to the *same* live session
  from your laptop. Don't `--continue`/`--resume` to switch surfaces — that
  starts a new process from transcript, a different session from the live one.
- **Terminal work is NOT mirrored to Telegram.** Claude only posts to the chat
  when it calls its `reply` tool, which it does in response to *Telegram* input —
  never automatically for terminal input. Work in the terminal with the phone
  closed and the Telegram chat stays silent; nothing is broadcast there.
- **But the context is shared.** Because it's one memory, anything from the
  terminal conversation is reachable over Telegram *on demand* — DM the bot
  "what were you working on?" and Claude can answer from the terminal context.
  Not auto-readable, but contextually reachable, so lock the channel to
  `allowlist` (your user ID only) before relying on it. For a session that's
  terminal-only with no Telegram reachability, just launch it **without**
  `--channels` — channels are per-session and opt-in at launch.

## One bot per project

To drive several projects from Telegram at once (e.g. `erdtree` and
`trino-rust-worker` in parallel), **create one bot per project** — don't share a
single bot across concurrent sessions.

**Why it's required, not just tidy.** A Telegram bot token allows exactly one
active `getUpdates` poller at a time. Launch two `claude --channels` sessions on
the same token and the second gets `409 Conflict`; they steal each other's
messages. The one-poller limit is at the token level, so group chats/topics
don't work around it — concurrent sessions need separate tokens. (A *single*
bot is fine if you only ever run one channel session at a time.)

Per-project also reads better on the phone: each bot is its own chat thread, so
DMing the "erdtree" chat unambiguously reaches the erdtree session, and each bot
keeps its own allowlist and inbox.

**Cost/limits:** bots are free (no charge to create or run); BotFather caps you
at ~20 bots per account, which is plenty. Delete unused ones with `/deletebot`.

**Convention** — keep setup mechanical:

- Bot username: `<you>_<project>_bot` (e.g. `richard_erdtree_bot`)
- State dir: `~/.claude/channels/telegram-<project>` (its own `.env` token,
  `access.json` allowlist, and `inbox/`)
- Launch, pointing the channel at that project's state dir:
  ```bash
  TELEGRAM_STATE_DIR=~/.claude/channels/telegram-<project> \
    claude --channels plugin:telegram@claude-plugins-official
  ```

Configure each project's token by exporting `TELEGRAM_STATE_DIR` before
`/telegram:configure` (it writes `<state-dir>/.env`), or write the `.env` by
hand. The default state dir (`~/.claude/channels/telegram/`) is just the
unnamed/first project — migrate it to a named dir for consistency once you add a
second bot, or leave it as-is.

## Verify

- `bun --version` → prints a version (prereq present).
- `/plugin` → Installed tab lists `telegram@claude-plugins-official`.
- After `--channels` launch, DM the bot → it answers with a pairing code (before
  pairing) or your message reaches Claude (after).

## Revert / disable

```
/telegram:access policy pairing     # loosen back to pairing, or
/plugin disable telegram@claude-plugins-official
/plugin uninstall telegram@claude-plugins-official
```
Token/state lives under `~/.claude/channels/telegram/` — delete that directory to
remove the saved token, pairing, and inbox.

## Sources

- Official README: <https://github.com/anthropics/claude-plugins-official/blob/main/external_plugins/telegram/README.md>
- Plugin page: <https://claude.com/plugins/telegram>
- Channels docs: <https://code.claude.com/docs/en/channels>

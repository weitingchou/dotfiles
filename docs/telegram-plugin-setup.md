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

- **Bun** — runtime the plugin's MCP server runs on. Installed once per machine.
  On macOS: `brew install bun` (shared via `/opt/homebrew`, like the rest of the
  toolchain).
- **BotFather** — Telegram's bot registrar. Creating a bot yields a **token**;
  whoever holds it controls the bot.
- **Plugin + channel** — the plugin is installed per Claude Code user; the
  channel is activated per session by launching with `--channels`.
- **Access policy** — `pairing` (anyone with a fresh code can attach) vs.
  `allowlist` (only enumerated user IDs). Lock to `allowlist` once paired.

## Prerequisites

- [x] **Bun** — `brew install bun` (macOS). Verify: `bun --version`.

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
- Multi-bot: point `TELEGRAM_STATE_DIR` at different directories per bot.

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

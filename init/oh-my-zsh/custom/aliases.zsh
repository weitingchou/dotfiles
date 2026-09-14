OSTYPE=`uname`

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done

# Detect which `ls` flavor is in use
# For `ls` color setting go check theme/richchou.theme
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi
alias ls="ls ${colorflag}"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# OS X has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Make Grunt print stack traces by default
command -v grunt > /dev/null && alias grunt="grunt --stack"

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
#alias stfu="osascript -e 'set volume output muted true'"
#alias pumpitup="osascript -e 'set volume 7'"

if [ $OSTYPE = "Darwin" ]; then
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
fi

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# Claude with custom kubeconfig
alias claude="KUBECONFIG=$HOME/.kube/claude-config CLAUDE_TELEMETRY=disabled claude"

# Launch Claude with a per-project Telegram channel. A Telegram bot token allows
# only one poller at a time, so concurrent projects each need their own bot and
# state dir (token, allowlist, inbox). This isolates state by project name:
#   claude-tg erdtree  ->  TELEGRAM_STATE_DIR=~/.claude/channels/telegram-erdtree
# Extra args pass through (e.g. claude-tg erdtree --dangerously-skip-permissions).
# Env mirrors the `claude` alias above (kubeconfig + telemetry) — keep in sync;
# we set it explicitly and use `command claude` rather than relying on the alias
# (zsh expands aliases at parse time, which is unreliable inside a function).
function claude-tg() {
    emulate -L zsh
    if [[ -z "$1" ]]; then
        print -u2 "usage: claude-tg <project> [extra claude args]   # e.g. claude-tg erdtree"
        return 1
    fi
    local project="$1"
    local dir="$HOME/.claude/channels/telegram-$project"
    shift
    # The plugin reads the token from $TELEGRAM_BOT_TOKEN or <state-dir>/.env;
    # without either it starts up and silently never polls. Fail loudly instead.
    if [[ -z "$TELEGRAM_BOT_TOKEN" && ! -s "$dir/.env" ]]; then
        print -u2 "claude-tg: no token for '$project'"
        print -u2 "run: claude-tg-init $project"
        return 1
    fi
    mkdir -p "$dir"
    KUBECONFIG="$HOME/.kube/claude-config" CLAUDE_TELEMETRY=disabled \
        TELEGRAM_STATE_DIR="$dir" \
        command claude --channels plugin:telegram@claude-plugins-official "$@"
}

# Bootstrap a project's Telegram state dir so claude-tg can launch it: writes the
# BotFather token to <state-dir>/.env (0600) and an allowlist-only access.json,
# then verifies the token against Telegram's getMe. Run once per new bot.
#   claude-tg-init erdtree            # prompts for the token (not echoed)
#   claude-tg-init erdtree 123:AAH... # or pass it (lands in shell history)
# The plugin's own /telegram:configure and /telegram:access skills can't do this:
# they hardcode ~/.claude/channels/telegram/ and ignore TELEGRAM_STATE_DIR, so on
# a per-project dir they'd edit the wrong file. See docs/telegram-plugin-setup.md.
function claude-tg-init() {
    emulate -L zsh
    local project="$1" token="$2"
    if [[ -z "$project" ]]; then
        print -u2 "usage: claude-tg-init <project> [token]   # e.g. claude-tg-init erdtree"
        return 1
    fi
    local dir="$HOME/.claude/channels/telegram-$project"

    if [[ -s "$dir/.env" ]]; then
        local reply
        read "reply?claude-tg-init: '$project' already has a token. Replace it? [y/N] "
        [[ "$reply" == [yY]* ]] || { print "aborted"; return 1 }
    fi

    if [[ -z "$token" ]]; then
        read -s "token?BotFather token for '$project': "
        print
    fi
    # BotFather tokens are <bot-id>:<secret>; catch a truncated paste early rather
    # than after a confusing 401 from getMe.
    if [[ ! "$token" =~ '^[0-9]+:[A-Za-z0-9_-]{30,}$' ]]; then
        print -u2 "claude-tg-init: that doesn't look like a bot token (expected 123456789:AA...)"
        return 1
    fi

    # Reuse the Telegram user ID already allowlisted on another project — it's the
    # same person every time, and it keeps a personal identifier out of this repo.
    local id f json field parts
    for f in $HOME/.claude/channels/telegram-*/access.json(N); do
        [[ "$f" == "$dir/access.json" ]] && continue
        json=$(tr -d ' \t\n' < "$f")
        field=${json#*'"allowFrom":['}
        field=${field%%']'*}
        parts=(${(s:,:)field})
        id=${parts[1]//\"/}
        [[ -n "$id" ]] && break
        id=
    done
    if [[ -z "$id" ]]; then
        read "id?Your numeric Telegram user ID (from @userinfobot): "
        if [[ ! "$id" =~ '^[0-9]+$' ]]; then
            print -u2 "claude-tg-init: user ID must be numeric"
            return 1
        fi
    fi

    mkdir -p "$dir" || return 1
    printf 'TELEGRAM_BOT_TOKEN=%s\n' "$token" > "$dir/.env" || return 1
    chmod 600 "$dir/.env"
    print "✓ $dir/.env (600)"

    # Don't clobber an allowlist that's already been curated (extra users, groups).
    if [[ -s "$dir/access.json" ]]; then
        print "• access.json exists — left as is"
    else
        cat > "$dir/access.json" <<JSON
{
  "dmPolicy": "allowlist",
  "allowFrom": ["$id"],
  "groups": {},
  "pending": {}
}
JSON
        print "✓ $dir/access.json — allowlist, user $id"
    fi

    # Confirms both that the token is live and that it's the bot you meant.
    local me=$(curl -fsS --max-time 10 "https://api.telegram.org/bot$token/getMe" 2>/dev/null)
    if [[ "$me" == *'"ok":true'* ]]; then
        local username=${${me#*'"username":"'}%%'"'*}
        print "✓ getMe: @$username"
    else
        print -u2 "✗ getMe failed — token rejected or network down; .env written anyway"
        return 1
    fi

    print "Now run: claude-tg $project"
}

# List configured Telegram channels (per-project + the default one). For each
# state dir under ~/.claude/channels it reports: bot id (the numeric prefix of
# the token, an offline identifier — run `curl .../getMe` for the @username),
# the access policy and allowlist size from access.json, and whether the poller
# is live (the server writes bot.pid into the state dir on launch). All offline,
# no network. Usage: claude-tg-ls
function claude-tg-ls() {
    emulate -L zsh
    setopt local_options null_glob
    local base="$HOME/.claude/channels"
    local -a dirs
    dirs=("$base"/telegram-*(N/) "$base"/telegram(N/))  # named dirs + default
    if (( ${#dirs} == 0 )); then
        print -- "No Telegram channels configured under $base."
        return 0
    fi
    printf '%-16s %-13s %-10s %-6s %s\n' PROJECT BOT-ID POLICY ALLOW RUNNING
    local d name line token botid policy allow pidf pid running
    for d in $dirs; do
        name=${d:t}
        [[ $name == telegram ]] && name='(default)' || name=${name#telegram-}
        botid='-'
        if [[ -f $d/.env ]]; then
            line=$(grep -m1 '^TELEGRAM_BOT_TOKEN=' "$d/.env" 2>/dev/null)
            token=${line#TELEGRAM_BOT_TOKEN=}
            [[ -n $token ]] && botid=${token%%:*}
        fi
        policy='-'; allow='-'
        if [[ -f $d/access.json ]] && command -v jq >/dev/null 2>&1; then
            policy=$(jq -r '.dmPolicy // "-"' "$d/access.json" 2>/dev/null)
            allow=$(jq -r '(.allowFrom // []) | length' "$d/access.json" 2>/dev/null)
        fi
        running='no'; pidf="$d/bot.pid"
        if [[ -f $pidf ]]; then
            pid=$(<"$pidf")
            if [[ -n $pid ]] && kill -0 $pid 2>/dev/null; then
                running="yes (pid $pid)"
            else
                running='no (stale pid)'
            fi
        fi
        printf '%-16s %-13s %-10s %-6s %s\n' "$name" "$botid" "$policy" "$allow" "$running"
    done
}

# ── Docker / Colima (macOS) ───────────────────────────────────────────────
# macOS has no native container engine; Colima runs a per-user Linux VM. These
# helpers give the account a one-command, idempotent start with a default dev
# profile. (Compose command aliases like `dco`, `dcup`, `dcdn` already come from
# the oh-my-zsh docker-compose plugin.)
if [ $OSTYPE = "Darwin" ]; then
    # Default VM profile. This box is dedicated to the agent (sandbox) user for
    # development, so the VM gets the lion's share; the remainder is left for
    # macOS + host-side tooling (Claude Code, node, nvim, builds). Colima applies
    # these on (re)start — bump a value and re-run `dkup` to resize. The disk is
    # sparse: it grows on demand and does not reserve the full size up front.
    export COLIMA_CPU=8        # of 10 cores  (leave 2 for the host)
    export COLIMA_MEMORY=10    # of 16 GB     (leave ~6 GB for macOS + host tools)
    export COLIMA_DISK=100     # GB           (sparse)

    # Start the daemon only if it isn't already up; safe to run repeatedly.
    function dkup() {
        if colima status >/dev/null 2>&1; then
            colima status
        else
            colima start \
                --cpu "$COLIMA_CPU" --memory "$COLIMA_MEMORY" --disk "$COLIMA_DISK" \
                --vm-type vz --mount-type virtiofs
            #     └ Apple Virtualization.framework + fast virtiofs file sharing.
            # To also run x86/amd64 images, install Rosetta once (an admin runs:
            #   softwareupdate --install-rosetta --agree-to-license) then add
            #   --vz-rosetta to the line above.
        fi
    }

    alias dkdown='colima stop'      # reclaim CPU/RAM when done for the session
    alias dkstatus='colima status'
fi

unset OSTYPE

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

# https://github.com/blinks zsh theme

if type $(tput setaf 1) &> /dev/null; then
    tput sgr0; # reset colors
    bold=$(tput bold);
    reset=$(tput sgr0);
    # Solarized colors, taken from http://git.io/solarized-colors.
    black=$(tput setaf 0);
    blue=$(tput setaf 33);
    cyan=$(tput setaf 37);
    green=$(tput setaf 64);
    orange=$(tput setaf 166);
    purple=$(tput setaf 125);
    red=$(tput setaf 124);
    violet=$(tput setaf 61);
    white=$(tput setaf 15);
    gray=$(tput setaf 246);
    yellow=$(tput setaf 136);
else
    ld='';
    reset="\e[0m";
    black="0";
    blue="33";
    cyan="37";
    green="64";
    orange="166";
    purple="125";
    red="124";
    violet="61";
    white="15";
    gray="246";
    yellow="136";
fi;

# This theme works with both the "dark" and "light" variants of the
# Solarized color schema.  Set the SOLARIZED_THEME variable to one of
# these two values to choose.  If you don't specify, we'll assume you're
# using the "dark" variant.

case ${SOLARIZED_THEME:-dark} in
    light) bkg=${white};;
    *)     bkg=${black};;
esac

# Git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" [%{%B%F{blue}%}";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%f%k%b%K{${bkg}}%B%F{green}%}]";
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{red}%}*%{%f%k%b%}";
ZSH_THEME_GIT_PROMPT_CLEAN="";
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{%F{red}%}?%{%f%k%b%}";
ZSH_THEME_GIT_PROMPT_ADDED=" %{%F{red}%}+%{%f%k%b%}";
ZSH_THEME_GIT_PROMPT_DELETED=" %{%F{red}%}-%{%f%k%b%}";
ZSH_THEME_GIT_PROMPT_MODIFIED=" %{%F{red}%}!%{%f%k%b%}";
ZSH_THEME_GIT_PROMPT_STASHED=" %{%F{red}%}$%{%f%k%b%}";

# Primary prompt
# See http://www.nparikh.org/unix/prompt.php#zsh
# Highlight the user name when logged in as root.
if [[ "${USER}" == "root"  ]]; then
    userStyle="${red}";
else
    userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}"  ]]; then
    hostStyle="${red}";
else
    hostStyle="${yellow}";
fi;

# Set primary prompt
PROMPT='%{%f%k%b%}';                                            # reset all the settings
PROMPT+='%{%K{${bkg}}%B%F{${userStyle}}%}%n%{$reset_color%}';   # username
PROMPT+='%{%K{${bkg}}%B%F{${gray}}%}@%{$reset_color%}';         # `@`
PROMPT+='%{%K{${bkg}}%B%F{${hostStyle}}%}%m%{$reset_color%}';   # host
PROMPT+='%{%K{${bkg}}%} ';                                      # white space
PROMPT+='%{%K{${bkg}}%F{${green}}%}%~%{$reset_color%}';         # working directory
PROMPT+='%{%K{${bkg}}%}$(git_prompt_info)%E%{$reset_color%}';   # Git repository details
PROMPT+='%{%F{${gray}}%} $ %{$reset_color%}%{%f%k%b%}';         # `$` (and reset color)


# Right prompt
RPROMPT='$(git_prompt_status)%E%{%f%k%b%}';

# Color "ls"
# Detect which `ls` flavor is in use
# See http://geoff.greer.fm/lscolors/
#     http://www.bigsoft.co.uk/blog/index.php/2008/04/11/configuring-ls_colors
#     https://github.com/mathiasbynens/dotfiles/blob/aff769fd75225d8f2e481185a71d5e05b76002dc/.aliases#L21-26
if ls --color > /dev/null 2>&1; then # GUN `ls`
    colorflag="--color";
    export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=31:cd=31:su=31:sg=31:tw=31:ow=31:or=40;31;01:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;"
else #macOS `ls`
    colorflag="-G";
    export LSCOLORS="exfxcxdxbxbxbxbxbxbxbx";
fi

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}";

# Always enable colored `grep` output
export GREP_OPTIONS='--color=auto';

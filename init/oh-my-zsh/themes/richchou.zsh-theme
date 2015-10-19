# https://github.com/blinks zsh theme

# This theme works with both the "dark" and "light" variants of the
# Solarized color schema.  Set the SOLARIZED_THEME variable to one of
# these two values to choose.  If you don't specify, we'll assume you're
# using the "dark" variant.

case ${SOLARIZED_THEME:-dark} in
    light) bkg=white;;
    *)     bkg=black;;
esac

# Git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" [%{%B%F{blue}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%f%k%b%K{${bkg}}%B%F{green}%}]"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{red}%}*%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{%F{red}%}?%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_ADDED=" %{%F{red}%}+%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_DELETED=" %{%F{red}%}-%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %{%F{red}%}!%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_STASHED=" %{%F{red}%}$%{%f%k%b%}"

# Primary prompt
# See http://www.nparikh.org/unix/prompt.php#zsh
function _prompt_char() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    echo "%{%F{blue}%}±%{%f%k%b%}"
  else
    echo ' '
  fi
}

PROMPT='%{%f%k%b%}
%{%K{${bkg}}%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%K{${bkg}}%}%~%{%B%F{green}%}$(git_prompt_info)%E%{%f%k%b%} $%{%f%k%b%} '

#PROMPT='%{%f%k%b%}
#%{%K{${bkg}}%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%K{${bkg}}%}%~%{%B%F{green}%}$(git_prompt_info)%E%{%f%k%b%}
#%{%K{${bkg}}%}$(_prompt_char)%{%K{${bkg}}%} %#%{%f%k%b%} '

# Right prompt
#RPROMPT='!%{%b%f{cyan}%}%!%{%f%k%b%}'
RPROMPT='$(git_prompt_status)%E%{%f%k%b%}'

# Color "ls"
# See http://geoff.greer.fm/lscolors/
export LSCOLORS="exfxcxdxbxbxbxbxbxbxbx"
export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=31;40:cd=31;40:su=31;40:sg=31;40:tw=31;40:ow=31;40:"

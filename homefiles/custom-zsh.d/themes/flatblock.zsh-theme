prompt_color="%F{248}"
curdir_color="%F{034}"
secondary_color="%F{232}"

current_path="%(5~|%-1~/.../%3~|%~)"

PROMPT="\$(__statusline)
${curdir_color}%B${current_path}%f%b \$(__git_prompt)${prompt_color}%(!.#.$) %f"
PROMPT2="${prompt_color}> %f"

RPROMPT="${secondary_color}%B%n@%m%b%f"

VIRTUAL_ENV_DISABLE_PROMPT=1

function __statusline {
  local code="$?"

  local rmargin=$COLUMNS
  local elements=()
  local strcount

  # status code
  if [ $code -eq 0 ]; then
    code="%F{002}$code%f"
  else
    code="%F{001}$code%f"
  fi
  strcount=$(( ${#code} - 7 ))
  if [ $rmargin -ge $strcount ]; then
    elements+=("$code")
    let rmargin-=$strcount
  fi

  # time
  local hhmmss="$(date +"%H:%M:%S")"
  strcount=$(( ${#hhmmss} + 3 ))
  if [ $rmargin -ge $strcount ]; then
    elements+=("$hhmmss")
    let rmargin-=$strcount
  fi

  # python virtualenv
  local pyvenv=$(__pyvenv)
  strcount=$(( ${#pyvenv} + 3 ))
  if [ -n "$pyvenv" ] && [ $rmargin -ge $strcount ]; then
    elements+=("$pyvenv")
    let rmargin-=$strcount
  fi

  # construct status lne
  local info="${secondary_color}"
  for i in {1..$#elements}; do
    local tmp="[${elements[$i]}${secondary_color}]"
    if [ $i -eq 1 ]; then
      info+="$tmp"
    else
      info+="-$tmp"
    fi
  done

  [ $rmargin -lt 0 ] && rmargin=0
  echo "${info}${(l.rmargin..-.)}%f"
}

function __pyvenv {
  local pyvenv_dir="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"
  local pyvenv="${pyvenv_dir##*/}"
  if [ -n "$pyvenv" ]; then
    echo "py:$pyvenv"
  fi
}

# git settings
function __git_prompt() {
  if ! __git_prompt_git rev-parse --git-dir &>/dev/null \
     || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    return 0
  fi

  ref=$(__git_prompt_git symbolic-ref --short HEAD 2>/dev/null) ||
    ref="tag:$(__git_prompt_git describe --tags --exact-match HEAD 2>/dev/null)" ||
    ref="ref:$(__git_prompt_git rev-parse --short HEAD 2>/dev/null)" ||
    return 0

  echo "%f%b(%B%F{062}${ref:gs/%/%%}%b%f$(git_prompt_status)%f%b)"
}

ZSH_THEME_GIT_PROMPT_PREFIX="%f%b("
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b)"
ZSH_THEME_GIT_PROMPT_DELETED="%F{178}-"
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{213}*"
ZSH_THEME_GIT_PROMPT_ADDED="%F{010}+"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{009}?"
ZSH_THEME_GIT_PROMPT_RENAMED="%F{031}~"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{124}!"
ZSH_THEME_GIT_PROMPT_AHEAD="%f>"
ZSH_THEME_GIT_PROMPT_BEHIND="%f<"
ZSH_THEME_GIT_PROMPT_DIVERGED="%f<>"
ZSH_THEME_GIT_PROMPT_STASHED="%F{027}.."

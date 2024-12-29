prompt_color="%F{248}"
curdir_color="%F{034}"
status_ok_color="%F{002}"
status_error_color="%F{001}"
secondary_color="%F{241}"

ZSH_PYENV_VIRTUALENV=0

if [ -z $FLATBLOCK_PYENV_ENABLE ]; then
  FLATBLOCK_PYENV_ENABLE=0
fi

if [ -z $FLATBLOCK_TIME_FORMAT ]; then
  FLATBLOCK_TIME_FORMAT='%H:%M:%S'
fi

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

current_path="%(5~|%-1~/.../%3~|%~)"

PROMPT="\${secondary_color}\$(__statusline)%f
\${curdir_color}%B\${current_path}%f%b\$(__git_prompt)\${prompt_color}%(!.#.$) %f"
PROMPT2="${prompt_color}> %f"

RPROMPT="${secondary_color}%B%n@%m%b%f"

__statusline() {
  local code="$?"
  if [ $code -eq 0 ]; then
    colorlized_code="${status_ok_color}$code"
  else
    colorlized_code="${status_error_color}$code"
  fi
  colorlized_code+="${secondary_color}"

  local rmargin=$COLUMNS
  local line=""

  add_element() {
    if [ -z $1 ]; then
      return
    fi

    # add separator if needed
    if [ ${#line} -gt 0 ]; then
      if [ $rmargin -gt 0 ]; then
        rmargin=$(($rmargin - 1))
        line+='-'
      else
        return
      fi
    fi

    # $1: str, $2: rawstr
    local str=$1
    local raw=${2:-$1}
    local strcount=$(( ${#raw} + 2 ))

    if [ $rmargin -ge $strcount ]; then
      line+="[$str]"
      rmargin=$(($rmargin - $strcount))
    fi
  }

  add_element $colorlized_code $code
  add_element $(strftime $FLATBLOCK_TIME_FORMAT $EPOCHSECONDS)

  # python virtualenv (optional)
  if [[ $FLATBLOCK_PYENV_ENABLE -eq 1 ]]; then
    add_element `__pyvenv`
  fi

  if (( rmargin > 0 )); then
    line+="${__padding[1,$rmargin]}"
  fi
  echo $line
}

__pyvenv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
   echo "py:%s" ${VIRTUAL_ENV:t}
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
   echo "py:%s" ${CONDA_DEFAULT_ENV}
  fi
}

# git settings
__git_prompt() {
  if [[ $__git_prompt_enable -eq 0 ]]; then
    __git_prompt_cache=""
    return
  fi

  if [ -z __git_prompt_cache ]; then
    return
  fi

  if ref=$(git symbolic-ref --short HEAD 2>/dev/null); then
  elif ref=$(git describe --tags --exact-match HEAD 2>/dev/null); then
  elif ref=$(git rev-parse --short HEAD 2>/dev/null); then
  fi

  if [ -z "$ref" ]; then
    __git_prompt_cache=""
  else
    __git_prompt_cache="%f%b(%B%F{062}${ref:gs/%/%%}%b%f$(git_prompt_status)%f%b)"
  fi

  echo $__git_prompt_cache
}

__init_git_prompt() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null || [[ "$(git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    __git_prompt_enable=0
  else
    __git_prompt_enable=1
  fi
  __git_prompt_cache=""
}

chpwd() {
  __init_git_prompt
}

PERIOD=2
periodic() {
  __padding=${(l:$((COLUMNS * 3))::-:)}
  __init_git_prompt
}

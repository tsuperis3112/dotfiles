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
  local colorlized_code
  
  # Fast color selection
  if [[ $code -eq 0 ]]; then
    colorlized_code="${status_ok_color}$code${secondary_color}"
  else
    colorlized_code="${status_error_color}$code${secondary_color}"
  fi

  local rmargin=$COLUMNS
  local line=""

  # Optimized add_element function with early returns
  add_element() {
    [[ -z $1 ]] && return
    
    local str=$1
    local raw=${2:-$1}
    local strcount=$(( ${#raw} + 2 ))
    
    # Early return if not enough space
    [[ $rmargin -lt $strcount ]] && return
    
    # Add separator if line already has content
    if [[ ${#line} -gt 0 ]]; then
      [[ $rmargin -le 0 ]] && return
      line+='-'
      ((rmargin--))
      [[ $rmargin -lt $strcount ]] && return
    fi

    line+="[$str]"
    ((rmargin -= strcount))
  }

  # Add elements with early termination
  add_element $colorlized_code $code
  [[ $rmargin -le 0 ]] && { echo $line; return; }
  
  add_element $(strftime $FLATBLOCK_TIME_FORMAT $EPOCHSECONDS)
  [[ $rmargin -le 0 ]] && { echo $line; return; }

  # Python virtualenv (only if enabled)
  if [[ $FLATBLOCK_PYENV_ENABLE -eq 1 ]]; then
    local pyvenv_info=$(__pyvenv)
    [[ -n $pyvenv_info ]] && add_element $pyvenv_info
  fi

  # Add padding only if there's remaining space
  if (( rmargin > 0 )); then
    line+="${__padding[1,$rmargin]}"
  fi
  
  echo $line
}

# Optimized Python environment detection
__pyvenv() {
  # Fast path: check most common case first
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "py:${VIRTUAL_ENV:t}"
    return
  fi
  
  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "py:$CONDA_DEFAULT_ENV"
    return
  fi
  
  # Return empty if no environment found
}

__init_git_prompt() {
  # Fast check: exit early if not in git repo
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    __git_prompt_enable=0
    __git_prompt_cache=""
    return
  fi
  
  # Check if git info is hidden
  if [[ "$(git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    __git_prompt_enable=0
    __git_prompt_cache=""
    return
  fi
  
  __git_prompt_enable=1
  __git_prompt_cache=""  # Clear cache to force refresh
}

__update_git_prompt() {
  local ref=""
  
  # Fast path: try symbolic-ref first (most common case)
  if ref=$(git symbolic-ref --short HEAD 2>/dev/null); then
    # Branch found
  elif ref=$(git describe --tags --exact-match HEAD 2>/dev/null); then
    # Tag found
  elif ref=$(git rev-parse --short HEAD 2>/dev/null); then
    # Commit hash found
  fi

  if [[ -z "$ref" ]]; then
    __git_prompt_cache=""
  else
    # Only call git_prompt_status if we have a ref (expensive operation)
    local git_status=""
    if command -v git_prompt_status >/dev/null 2>&1; then
      git_status="$(git_prompt_status)"
    fi
    __git_prompt_cache="%f%b(%B%F{062}${ref:gs/%/%%}%b%f${git_status}%f%b)"
  fi
}

# Initialize theme variables and cache
__flatblock_init() {
  # Initialize git prompt
  __init_git_prompt
  
  # Initialize padding cache
  __padding_cache=${(l:$((COLUMNS * 3))::-:)}
  __last_columns=$COLUMNS
  __padding=$__padding_cache
}

# Initialize on theme load
__flatblock_init

# git settings - optimized with caching
__git_prompt() {
  # Return cached result if git is disabled or not in git repo
  if [[ $__git_prompt_enable -eq 0 ]]; then
    return
  fi

  # Return cached result if available and fresh
  if [[ -n "$__git_prompt_cache" ]]; then
    echo $__git_prompt_cache
    return
  fi

  # Generate new git prompt info
  __update_git_prompt
  echo $__git_prompt_cache
}

# Optimized directory change handler
chpwd() {
  __init_git_prompt
  # Invalidate padding cache on terminal resize
  unset __padding_cache
}

# Optimized periodic function
PERIOD=5  # Reduced frequency from 2 to 5 seconds
periodic() {
  # Cache padding calculation
  if [[ -z "$__padding_cache" || $__last_columns -ne $COLUMNS ]]; then
    __padding_cache=${(l:$((COLUMNS * 3))::-:)}
    __last_columns=$COLUMNS
  fi
  __padding=$__padding_cache
  
  # Refresh git info only if in git repo
  if [[ $__git_prompt_enable -eq 1 ]]; then
    __git_prompt_cache=""  # Clear cache to force refresh
  fi
}

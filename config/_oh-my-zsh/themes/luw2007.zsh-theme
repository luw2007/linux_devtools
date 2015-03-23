# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR='⮀'
RSEGMENT_SEPARATOR='⮂'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

rprompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  
   echo -n "%K{$CURRENT_BG}%F{$1}$RSEGMENT_SEPARATOR%{$bg%}%{$fg%}"
#  if [[ $CURRENT_BG != 'NONE' && $2 != $CURRENT_BG ]]; then
#    echo -n "%K{$CURRENT_BG}%F{$1}$RSEGMENT_SEPARATOR%{$bg%}%{$fg%}"
#  else
#    echo -n "%F{$1}%K{$2}$RSEGMENT_SEPARATOR%{$bg%}%{$fg%}"
#  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{%f%}"
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
rprompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    rprompt_segment green black "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment red black
    else
      prompt_segment green black
    fi
    echo -n "${ref/refs\/heads\//⭠ }$dirty"
  fi
}

prompt_hg() {
	local rev status
	if $(hg id >/dev/null 2>&1); then
		if $(hg prompt >/dev/null 2>&1); then
			if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
				# if files are not added
				prompt_segment red white
				st='±'
			elif [[ -n $(hg prompt "{status|modified}") ]]; then
				# if any modification
				prompt_segment yellow black
				st='±'
			else
				# if working copy is clean
				prompt_segment green black
			fi
			echo -n $(hg prompt "⭠ {rev}@{branch}") $st
		else
			st=""
			rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
			branch=$(hg id -b 2>/dev/null)
			if `hg st | grep -Eq "^\?"`; then
				prompt_segment red black
				st='±'
			elif `hg st | grep -Eq "^(M|A)"`; then
				prompt_segment yellow black
				st='±'
			else
				prompt_segment green black
			fi
			echo -n "⭠ $rev@$branch $st"
		fi
	fi
}

# Dir: current working directory
rprompt_dir() {
  rprompt_segment white black '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] || symbols="$"
  prompt_segment black magenta "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_git
  prompt_hg
  prompt_end
}

build_rprompt() {
  rprompt_dir
  rprompt_context
}

PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT=' $(build_rprompt)%{%f%b%k%}'


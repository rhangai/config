source "$ZSH/themes/bira.zsh-theme"

ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="%{$fg_bold[green]%}%{✔%{$fg_no_bold[yellow]%}%G%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"

function git_prompt_info() {
	local current_branch=$(git_current_branch)
	if [[ -n "$current_branch" ]]; then
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX$current_branch$(parse_git_dirty)$(git_prompt_info_remote)$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}

function git_prompt_info_remote() {
	if [[ -n "$(__git_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]; then
		local commits_ahead=$(git_commits_ahead)
		local commits_behind=$(git_commits_behind)
		local STATUS=''
		
		if [[ $commits_ahead -eq 0 ]] && [[ $commits_behind -eq 0 ]]; then
			STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE";
		else
			STATUS="$STATUS${commits_behind:-0}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE "
			STATUS="$STATUS${commits_ahead:-0}$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
		fi
		if [[ -n $STATUS ]]; then
			echo " $STATUS"
		fi
	fi
 }
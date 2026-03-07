#!/bin/bash

# pure prompt on bash
#
# Pretty, minimal BASH prompt, inspired by sindresorhus/pure(https://github.com/sindresorhus/pure)
#
# Author: Hiroshi Krashiki(Krashikiworks)
# released under MIT License, see LICENSE

# Colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT_BLACK=$(tput setaf 8)
BRIGHT_RED=$(tput setaf 9)
BRIGHT_GREEN=$(tput setaf 10)
BRIGHT_YELLOW=$(tput setaf 11)
BRIGHT_BLUE=$(tput setaf 12)
BRIGHT_MAGENTA=$(tput setaf 13)
BRIGHT_CYAN=$(tput setaf 14)
BRIGHT_WHITE=$(tput setaf 15)

RESET=$(tput sgr0)

# symbols
pure_prompt_symbol="❯"
pure_symbol_unpulled="⇣"
pure_symbol_unpushed="⇡"
pure_symbol_dirty="*"

# if this value is true, remote status update will be async


# if last command failed, change prompt color
__pure_echo_prompt_color() {

	if [[ $? = 0 ]]; then
		echo ${pure_user_color}
	else
		echo ${RED}
	fi

}

__pure_update_prompt_color() {
	pure_prompt_color=$(__pure_echo_prompt_color)
}

# if user is root, prompt is BRIGHT_YELLOW
case ${UID} in
	0) pure_user_color=${BRIGHT_BLUE} ;;
	*) pure_user_color=${BRIGHT_BLUE} ;;
esac

PROMPT_COMMAND="__pure_update_prompt_color; ${PROMPT_COMMAND}"


FIRST_LINE="${CYAN}\w \n"
# raw using of $ANY_COLOR (or $(tput setaf ***)) here causes a creepy bug when go back history with up arrow key
# I couldn't find why it occurs
SECOND_LINE="\[\${pure_prompt_color}\]${pure_prompt_symbol}\[$RESET\] "
PS1="\n${FIRST_LINE}${SECOND_LINE}"

# Multiline command
PS2="\[$BLUE\]${prompt_symbol}\[$RESET\] "

#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eo pipefail
unalias -a

TERMINAL_LOGGER_DIRECTORY="$HOME/.terminal-logger"
install -d "$TERMINAL_LOGGER_DIRECTORY"
{
        TERMINAL_LOG_HEAD="$TERMINAL_LOGGER_DIRECTORY/terminal."
        TERMINAL_LOG="${TERMINAL_LOG_HEAD}log"
        TERMINAL_LOGS="$TERMINAL_LOGGER_DIRECTORY/terminal*.log"
        TERMINAL_LOG_PATTERN='terminal\.([1-9][0-9]*)\.log'
        if [[ -e "$TERMINAL_LOG" ]]
        then exec 3>"${TERMINAL_LOG_HEAD}$(($({
                for terminal_log in $TERMINAL_LOGS
                do
                        if [[ $terminal_log =~ $TERMINAL_LOG_PATTERN ]]
                        then echo "${BASH_REMATCH[1]}"
                        fi
                done
        }|sort -n|tail -n1) + 1)).log"
        else exec 3>"$TERMINAL_LOG"
        fi
} 4>"$TERMINAL_LOGGER_DIRECTORY/lock"
DATE_FORMAT='+%Y%m%dT%H%M%S%z'

function format {
        while IFS= read -r x
        do stdbuf -o0 -e0 printf "%s %s%s%s\n" "$(
                stdbuf -o0 -e0 date "$DATE_FORMAT")" "$1" "$x" "$2"
        done
}

date "$DATE_FORMAT" >&3
echo "$@" >&3
{ { { { { {
        "$@" 4>&-|tee /dev/stderr 2>&4 4>&-
} 2>&1 >&6|tee /dev/stderr 2>&5 4>&- 5>&- 6>&-
} >&7
} 6>&1|format >&3 4>&- 5>&- 6>&- 7>&-
} 7>&1|format '[1;41m' '[0m' >&3 4>&- 5>&- 6>&- 7>&-
} 4>&1
} 5>&2

#! /bin/bash

ACTIVE_WINDOW=$(xdotool getactivewindow)
ACTIVE_WM_CLASS=$(xprop -id "$ACTIVE_WINDOW" | grep WM_CLASS)
if expr "$ACTIVE_WM_CLASS" : ".*Alacritty" ; then
    # Get PID. If _NET_WM_PID isn't set, bail.
    PID=$(xprop -id "$ACTIVE_WINDOW" | grep _NET_WM_PID | grep -oP "\d+")
	[ -z "$PID" ] && alacritty

    # Get first child of terminal
    CHILD_PID=$(pgrep -P "$PID")

    # Get current directory of child. The first child should be the shell.
    pushd "/proc/${CHILD_PID}/cwd" || exit 1
    SHELL_CWD=$(pwd -P)
	popd || exit 1

    alacritty --working-directory "$SHELL_CWD"
else
    alacritty
fi

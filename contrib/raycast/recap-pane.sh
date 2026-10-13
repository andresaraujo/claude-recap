#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Recap Claude Pane
# @raycast.mode fullOutput
# @raycast.packageName Claude Recap
# @raycast.icon 🎧
# @raycast.argument1 { "type": "text", "placeholder": "herdr pane (blank = focused)", "optional": true }
# @raycast.description Spoken recap of a Claude session's last turns, plus the script as text

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
# resolve symlinks so this works when linked into another script directory
HERE=$(dirname "$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$0")")
exec python3 "$HERE/../../bin/recap" --print ${1:+--pane "$1"}

#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Stop Recap
# @raycast.mode silent
# @raycast.packageName Claude Recap
# @raycast.icon ⏹️

HERE=$(dirname "$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$0")")
exec python3 "$HERE/../../bin/recap" --stop

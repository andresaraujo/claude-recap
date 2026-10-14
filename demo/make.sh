#!/usr/bin/env bash
# Builds the README demo from a made-up session: real recap pipeline for the audio, a recorded HTML scene for the picture.
# Needs: claude (signed in), pocket-tts, ffmpeg, Node, Google Chrome. Output: demo/out/demo.mp4 + poster.png
set -euo pipefail
cd "$(dirname "$0")"
[ -d node_modules ] || npm install --silent
if [ ! -f recap.wav ] || [ "${FRESH:-}" = 1 ]; then   # FRESH=1 asks Haiku for a new script
	../bin/recap --transcript session.jsonl --print --no-play --out recap.wav | sed '/^$/q' | sed '/^$/d' > recap.txt
fi
node make.mjs

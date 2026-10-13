---
name: recap
description: Play a short spoken audio recap of this session's last few turns. Only when the user runs /recap or asks to hear a recap.
disable-model-invocation: true
---

Run the recap script with the Bash tool, exactly once. It is two levels up from this skill's base directory:

`python3 "<this skill's base directory>/../../bin/recap"`

It finds this session by itself and summarizes the transcript outside this session.

Then reply with only the one line it printed, for example `▶ playing 28s recap · voice alba · stop: recap --stop`. Don't summarize the session yourself, don't add a status line, and don't repeat the recap text. The point is to keep this session's context small.

If it fails, reply with its one-line error.

# claude-recap

Hear a ~30-second spoken recap of a Claude Code session when you come back to it.

`recap` reads the session's saved transcript, takes your last few prompts and Claude's final replies, has Haiku write a short spoken script, and reads it aloud. All of this runs **outside** the session, so its context does not grow.

```
▶ playing 28s recap · voice alba · stop: recap --stop
```

macOS only for now.

## Install

1. **The `/recap` command** (Claude Code plugin):
   ```
   claude plugin marketplace add andresaraujo/claude-recap   # or a local path to this repo
   claude plugin install recap@claude-recap
   ```
2. **A good voice (optional, recommended):** `uv tool install pocket-tts`.
   [Pocket TTS](https://github.com/kyutai-labs/pocket-tts) is a 100M-parameter model that runs on the CPU, about 10× faster than real time on Apple Silicon. Without it, recap uses macOS `say`.
3. **`recap` in your terminal (optional):** `ln -s "$PWD/bin/recap" /opt/homebrew/bin/recap`

Needs `python3` (3.9+) and the `claude` CLI, signed in.

## Use

| Where | How |
|---|---|
| Claude Code | `/recap` |
| Terminal | `recap`, `recap --pane w5:p1`, `recap --session <id>`, `recap --stop` |
| herdr | **prefix+a** recaps the focused pane, **prefix+shift+a** stops (see below) |
| Raycast | **Recap Claude Pane** and **Stop Recap** (see below) |

Run `recap --help` for every flag. `recap --text "..." --out f.wav --no-play` speaks any text, so other tools can reuse your engine and voice.

**Which session it picks:** `--transcript` / `--session` / `--pane` if given; otherwise the session it runs inside (`/recap`); otherwise the herdr pane it runs in, or the focused herdr agent; otherwise the newest transcript for the current folder.

## Config

`~/.config/claude-recap/config.json` (all optional):

```json
{ "engine": "auto", "voice": "alba", "say_voice": "", "turns": 3, "model": "haiku" }
```

- `engine`: `auto` (Pocket TTS if installed, else `say`), `pocket`, or `say`.
- `voice`: a Pocket TTS voice. Run `recap --samples` to hear them all. Each voice has its own license: see [kyutai/tts-voices](https://huggingface.co/kyutai/tts-voices).
- `claude`, `pocket_tts`: binary paths, if they're not on PATH.

`recap --config` prints the effective settings.

## herdr

```
herdr plugin link /path/to/claude-recap/contrib/herdr
```
Then add to `~/.config/herdr/config.toml` and run `herdr server reload-config`:
```toml
[[keys.command]]
key = "prefix+a"
type = "plugin_action"
command = "local.recap.play"
description = "recap: play"

[[keys.command]]
key = "prefix+shift+a"
type = "plugin_action"
command = "local.recap.stop"
description = "recap: stop"
```
A toast shows while the recap is prepared.

## Raycast

Raycast → Settings → Extensions → Script Commands → Add Directory → `contrib/raycast`. You can also symlink the two scripts into a folder you already use.

## Privacy

Your last few turns, trimmed and with code blocks and URLs removed, are sent to Claude (Haiku) through your own `claude` login. Audio is made locally. Files live in `~/.cache/claude-recap`.

## How it stays fast

The summarizer is `claude -p` with hooks, MCP servers, tools and thinking turned off, and low effort. Without that, a user-level high-effort setting makes Haiku think for ~6k tokens (~60 s, not ~5 s).

## Develop

```
python3 -m unittest discover tests
```
The transcript `.jsonl` is Claude Code's internal format and may change. The parser skips anything it doesn't recognise; update `tests/fixture.jsonl` when the format moves.

The plugin is installed as a copy. After editing, bump `version` in `.claude-plugin/plugin.json`, then run:
```
claude plugin marketplace update claude-recap
claude plugin update recap@claude-recap
```

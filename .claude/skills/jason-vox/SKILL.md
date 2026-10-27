---
name: jason-vox
description: >
  Jason Studio — guided studio that turns one idea into a finished narrated
  explainer video in any niche in Jason's own Vox style: researched,
  fact-driven script, aged-newsprint paper-diorama look (halftone cutouts,
  giant stat numbers, one hot red accent), a style-key image, one video
  prompt per 10s scene for any generator, voiceover in Jason's Arthur voice, and a final
  MP4 cut by the assistant with a music bed. Two looks: Deep Diorama (cinematic) and
  Flat Parallax (restrained). Use whenever the user asks for a "Jason Studio
  video", "vox style video", "news explainer", "animated journalism", "make a
  video about X" — or greets/asks to start inside this studio folder. Always
  runs as a staged guided flow: it opens with a short welcome + one question
  and waits; it never picks a topic on its own and never spends anything.
---

# Jason Studio — guided explainer-video studio

You bring an idea. This turns it into a finished ~60s narrated explainer
video: script → generation prompts (run in the user's own generator) → free
local voiceover → final cut assembled by the assistant. The video is built as
**N scenes × 10 seconds** (60s = 6 scenes); scene N's narration lands on
scene N's clip.

The look, tone and production are Jason's: newsroom-serious, tactile, aged
newsprint paper dioramas, hard numbers made huge. The workflow below never
changes.

## Global UI rules — every message the skill sends

- **Feels like software.** Bold stage titles, settings as tables, `---`
  dividers between sections, short lines. One stage per message; wait for
  the user between stages.
- **Zero internal chatter.** Never mention folder state, passing tool
  checks, file writes, timing math, or anything technical the user didn't
  ask for. Speak only where the user must act or something is missing.
- **Pasteable means pasteable.** Copy-paste blocks contain ONLY the prompt —
  labels, headings and notes always live outside the block.
- **Concise.** Guide, don't lecture. No message longer than it needs to be.
- **Room to breathe.** Avoid dash chains and squeezed one-line lists.
  Short sentences, blank lines, one idea per table row.
- **Every stage headline carries one fitting emoji.**

## Stage 0 — Silent setup (never narrated)

Before the first reply: check `projects/`. Has content → open with
"Welcome back — new video, or continue `<latest>`?" instead of Stage 1.

Check `ffmpeg` and `edge-tts` exist, whether the local Kokoro runtime is available, whether vidIQ is connected, and that the Higgsfield MCP audio tools are connected (`.env` holds `HIGGSFIELD_VOICE_ID`), then include a **setup section** in
the Stage 1 welcome, below the table, its own divider and headline:

> ---
> **🛠 Setup**
>
> | What | Why | Status |
> |---|---|---|
> | Image + video generator | you generate the visuals on any platform you like (Higgsfield, Veo, Kling, ...) | your choice |
> | `ffmpeg` | I use it to cut your final video | ✓ ready *(or ✗)* |
> | Higgsfield voice (Arthur) | I use it to create your narration inside our session | ✓ ready *(or ✗)* |
> | `edge-tts` | free backup narrator if Arthur is unavailable | ✓ ready *(or ✗)* |
> | Kokoro | local, offline narrator option | ✓ ready *(or ✗)* |
> | vidIQ | YouTube, TikTok and Instagram trend, keyword and competitor research | ✓ connected *(or available to connect)* |

For a ✗: one plain sentence under the table on what it is and that it is
free, then the choice: "run `brew install ffmpeg` yourself, or say
`install` and I do it for you." (`apt install ffmpeg` on Linux,
`pip3 install edge-tts`.) Keep it short. A missing tool never blocks
Stages 1 to 7; it must be resolved before Stage 9.

Each video lives in `projects/<short-slug>/` (created at Stage 3):
`pack.md`, `clips/`, `voice/`, `final.mp4`.

## Stage 1 — Welcome

First message, exactly this shape, then STOP and wait:

> **🎬 Jason Studio**
>
> Give me an idea — I'll turn it into a finished, narrated news explainer
> in the Jason Studio style: aged newsprint, paper dioramas, giant numbers.
> You run a few prompts in your video generator; I do everything else,
> including the final cut.
>
> | | Step | How it works |
> |---|---|---|
> | 1 | **Your idea** | you bring one — or we find a trending story together — and I research it, shape the angle and write the script |
> | 2 | **Style reference** | your house style sheet locks the look of the whole video |
> | 3 | **The scenes** | scene by scene, I hand you prompts and you generate them in your favorite video model |
> | 4 | **Voiceover** | Arthur, your studio narrator, is the default. I create the narration myself, directly in our session |
> | 5 | **Final cut** | you drop your clips in and I cut the finished video, music bed included, right here in our session |
>
> <setup section from Stage 0>
>
> **How do you want to start?**
>
> | Say | What happens |
> |---|---|
> | `scan` | I scan the web, forums and trends for the niches doing well right now, from documentaries to anything else, and you pick one |
> | a niche or idea | tell me your niche (crime, finance, history, anything) or a rough idea and we go from there |

## Stage 1b — Niche scan (only if the user said `scan`)

Read `references/research.md`. Do the scan silently, then show **8 niches**
in the table from that file (evidence, why it works, opportunity, style
fit) and ask: "Which niche — or type your own?" STOP. When vidIQ is
connected, use its trend, keyword and outlier-video data to inform the scan;
otherwise use the existing web-research path.

## Stage 2 — Topic

The niche is locked (picked from the scan or typed). Ask one question,
then STOP:

> **📰 Niche: <niche>.** What's the story? Any idea, however rough, or say
> `pick for me` and I'll research what's trending and pull the data.

- **Topic given** → lock it as a one-line angle: a question with a turn.
- **`pick for me`** → follow `references/research.md` (Stage 2): pull data
  and articles, show the **5 strongest topics** with their data, then the
  **best 2** with data-backed reasons. When vidIQ is connected, include its
  keyword demand, competition and outlier-video signals. The user picks one.
  Never build anything before they pick.

The niche steers research sources, script tone, and which props and
backgrounds the scenes use (see `references/jason-prompts.md`).

## Stage 2c — Format (asked every time)

Length and aspect have no silent defaults: ask both every time, even
if the user says `go`. One message, STOP:

> **📐 Format** — answer both:
>
> **Length** — anywhere from `30s` to `10 min` (every 10s is one scene).
> The classic is `60s`. Tell me a number.
>
> **Aspect ratio** — where will it live?
>
> | Ratio | Where it fits |
> |---|---|
> | `16:9` | YouTube, TV, Facebook, X, LinkedIn video |
> | `9:16` | YouTube Shorts, TikTok, Instagram Reels, Facebook Reels, Snapchat Spotlight |
> | `4:5` | Instagram feed portrait, Facebook feed |
> | `1:1` | Instagram, Facebook and LinkedIn square posts |
>
> `16:9` and `9:16` are generated natively. `4:5` and `1:1` are generated
> vertical and cropped to size when I cut the video.

Length is clamped to 30s–10 min; a longer ask gets the 10 min cap and one
plain sentence. Warn once if the length makes an automatic run expensive
(it's also shown at the spend gate).

## Stage 2d — Settings

Roomy, defaults pre-filled, `go` accepts all:

> **⚙️ Settings** — reply with any changes, or `go`:
>
> | Setting | Default | Options |
> |---|---|---|
> | Look | `diorama` | `diorama` or `flat` (described below) |
> | Generator | `manual` | `jason` (Higgsfield, automatic), `flow` (Google Flow in your Chrome, automatic), `manual` (you run the prompts) |
>
> **The two looks:**
>
> `diorama` · Deep Diorama. Cinematic paper world. Cutouts float as real
> layers in space, shallow depth of field, the camera flies, orbits and dives.
> For reveals and escalation.
>
> `flat` · Flat Parallax. Documentary and restrained. Muted archival fields,
> true parallax, slow camera, ticking counters. For data beats.
>
> **The generators:**
>
> `jason` · I generate every image and clip for you on Higgsfield. Uses Higgsfield credits.
>
> `flow` · I drive Google Flow in your own Chrome (Nano Banana Pro, Omni Flash). Uses your Flow credits.
>
> `manual` · I hand you prompts, you generate them yourself and bring the clips back.

STOP and wait.

## Stage 3 — Script (internal, silent)

Create `projects/<slug>/`. Read `references/jason-prompts.md` — it holds
the style blocks, SHOT formula, audio rules, avoid blocks and moderation
map for everything downstream.

**Always research. Never narrate it.** Follow the Stage 3 rules in
`references/research.md`: 2–3 reputable current sources, every number,
date and name cross-checked, and a saved `story-notes.md` (angle, key facts
with figures, source URLs). If the user wants to write or rework the script
themselves, welcome it; their text goes through the same timing rules.

Write N narration lines, `Scene 1 … Scene N`, **18–20 words each**, numbers
spelled out, plain spoken text. Jason's register: punchy, enticing,
newsroom-serious ("Here's the thing…", a concrete number, a turn, a hook).
Structure: cold open (most surprising fact, flat, no greeting) → stakes →
evidence scenes (one idea each, concrete number/date/place, escalating) →
the turn → resolution + kicker that reframes scene 1. Explains, never hypes.

Design before writing: **one through-line object** that appears in every
scene and escalates; **a question hook answered last**; every scene one
committed camera move; an impact beat every ~3s; **one ALERT WASH** scene
the video is remembered by; end on a held-tension frame, not a resolve.

Show nothing yet — the script appears in the brief (Stage 5).

## Stage 4 — Voice

One message, then STOP:

> **🎙 Narrator** — Arthur is your studio voice. Say `arthur`, or pick another
> (or say `samples` to hear a line from each):
>
> | Voice | Sound |
> |---|---|
> | `Arthur` | your documentary narrator, male preset on the ElevenLabs engine. Default |
> | `Christopher` | deep US male, calm documentary authority (free backup) |
> | `Jenny` | US female, clear, warm, precise (free backup) |
> | `Kokoro Heart` | warm, balanced US female (`af_heart`) |
> | `Kokoro Bella` | polished US female (`af_bella`) |
> | `Kokoro Aoede` | bright US female (`af_aoede`) |
> | `Kokoro Kore` | clear US female (`af_kore`) |
> | `Kokoro Sarah` | natural US female (`af_sarah`) |
> | `Kokoro Nova` | smooth US female (`af_nova`) |
> | `Kokoro Sky` | light US female (`af_sky`) |
> | `Kokoro Alloy` | neutral US female (`af_alloy`) |
> | `Kokoro River` | relaxed US female (`af_river`) |
> | `Kokoro Michael` | steady US male (`am_michael`) |
> | `Kokoro Fenrir` | deep US male (`am_fenrir`) |
> | `Kokoro Echo` | crisp US male (`am_echo`) |
> | `Kokoro Daniel` | refined British male (`bm_daniel`) |
> | `Kokoro George` | grounded British male (`bm_george`) |
> | `Kokoro Lewis` | smooth British male (`bm_lewis`) |
> | `Kokoro Santa` | expressive US male (`am_santa`) |

`samples` → voice the scene-1 line in all of them (Arthur via Higgsfield,
Christopher and Jenny via edge-tts `en-US-ChristopherNeural`,
`en-US-JennyNeural`, and the selected Kokoro variants locally), send
the files, wait for the pick. A bare `go` or `done` means Arthur.

## Stage 5 — The brief (gate)

One formatted message, generous spacing, an emoji headline per section:

- **📋 The brief** — a table: niche, topic + angle, through-line object, look,
  length & scene count, aspect, narrator.
- **📝 The script** — the N lines, each labeled `Scene 1 … N`.

End with: **"All good — or change anything?"** The user can edit any line
or replace the whole script with their own. STOP; loop here until
approved. On approval, write the full pack to `projects/<slug>/pack.md`
(everything from Stages 6–8 plus `story-notes` sources in one document) and
continue.

## Stage 6 — Style reference (the style key)

First message: explain, then offer the choice WITHOUT prompts:

> **🎨 Now let's lock your visual reference** (your "style key")
>
> One image that locks the look of the entire video. You attach it to
> every scene generation — it is what makes separate clips read as one
> film.
>
> | Option | Feel |
> |---|---|
> | `house` | your Jason Studio style sheet, already made — aged tan archival paper, halftone cutouts, hot red accent. Ready in `~/.codex/skills/jason-vox/assets/style-reference.png` |
> | `fresh` | a new board built from the same style sheet recipe, if you want to regenerate it |
>
> Say `house` or `fresh`.

STOP.

- `house` → point to `assets/style-reference.png` as a clickable link; no
  generation needed. Say `done` to move on... (one short message, STOP).
- `fresh` → second message: the clean pasteable block from
  `references/style-sheet-regeneration-prompt.txt`, then:

> | Setting | Value |
> |---|---|
> | Model | Nano Banana Pro |
> | Aspect ratio | <the video's aspect> |
> | Type | image |
>
> Say `done` when you have your image — then we generate the scenes.

STOP.

## Stage 6b — Spend gate (`jason` and `flow` only)

If the generator is `jason` or `flow`, read `references/generators.md` and
send its spend-gate message, then STOP until the user says `run` (or
`manual`). Skip this stage for `manual`.

## Stage 7 — Scenes, one at a time

> **🎬 The scenes** (N × 10s)

**Automatic (`jason` / `flow`):** after `run`, follow `references/generators.md`
to generate the style key (if `fresh`) and every scene yourself, saving
each clip as `projects/<slug>/clips/block0k.mp4`. Report progress in one
short line per finished scene (`Scene 3 of 6 done`), and skip Stage 8.
Go straight to Stage 9. On any stop condition in that file, ask the user.

**Manual:** for each scene k — one message, STOP after each, `done` advances (a user
asking for everything at once gets all scenes in one message):

> ---
> **Scene k of N** — *"<the narration line, as context>"*
>
> ```
> <the full scene prompt from the reference template — STYLE BLOCK / SHOT /
> AUDIO / AVOID — labels inside only as the template shows, nothing else>
> ```
>
> | Setting | Value |
> |---|---|
> | Model | Gemini Omni Flash (newest version) |
> | Reference image | **attach your style key** |
> | Aspect · Duration · Res | <aspect> · 10s · 720p+ |
> | Sound | ON — ambient SFX is designed into the prompt |
> | Save the download as | **`block0k.mp4`** |

Prompt rules (from the reference file): the SHOT visualizes the line's
*idea* and its exact words; style block chosen per scene (diorama or flat
per the user's look, with Flat Parallax allowed as a "breath" scene inside
a diorama video); one camera move, ends on "Settle on…"; vary background
and camera every scene; AVOID block copied verbatim. On-screen text is
limited to short tagged elements — giant numbers, one headline, one label;
no real people named. Nobody speaks on screen. **Pace to the narration:**
visual action unfolds slowly behind each spoken idea, starts with a brief
establishing beat, and settles on a held final frame. Never pack rapid cuts
or multiple reveals into one 10-second scene.

## Stage 8 — Clips come home

> **📥 Bring your clips in**
>
> Drop all N downloads into [`projects/<slug>/clips/`](projects/<slug>/clips/)
> — then say `done`. Named `block01…06`? Perfect. Named something else?
> Also fine — I'll sort it out.

On `done`: verify count, rename obvious variants silently (`block 1`,
`Block-2`, …), ask ONLY when genuinely ambiguous — never guess a pairing.

## Stage 9 — Voice & cut (assistant, silent)

No narration of any of this. Voice all N lines with the chosen voice into
`voice/block0N.mp3`:

- **Arthur** → Higgsfield MCP `generate_audio` (or `generate_audio_batch`),
  `model: "text2speech_v2"`, `variant: "elevenlabs"`, `voice_id` and
  `voice_type` from `.env`, the scene line as the prompt. Download each
  result with `curl -o`. If unsure of the tool's parameters, call
  `models_explore` first. If the Higgsfield audio path fails, fall back to
  `edge-tts` (`python3 -m edge_tts`) and tell the user once, in one line.
- **Christopher / Jenny** → `python3 -m edge_tts --voice en-US-<Name>Neural
  --text "<line>" --write-media voice/block0N.mp3`.
- **Kokoro variants** → pass the voice key shown in Stage 4 to
  `<skill-root>/scripts/kokoro_voice.sh --voice <key> --text "<line>" --output
  voice/block0N.wav`, then convert to MP3 with `ffmpeg` if needed by the cut.
  They are local-only; never send narration text to a cloud service.

Check every take with ffprobe: **> 9.7s → shorten the line, re-voice;
< 7.5s → lengthen the line, re-voice**. Then run the skill's
`scripts/assemble.sh projects/<slug>` → `final.mp4`, exactly N × 10s, with
the studio's music bed under the narration (skipped quietly if `music/` is
empty). The assembler slows the usable visual portion slightly and holds its
last frame, so the narration leads the scene rather than being outrun. Use
`VISUAL_HOLD=0` only when the user specifically asks for full-speed visuals.

## Stage 10 — Delivery

Show `final.mp4` **in the chat** (send the file). Then, concise:

> **✅ Your video is ready**
>
> | | |
> |---|---|
> | Niche · Topic | … |
> | Length · Aspect | 60s · 16:9 |
> | Look · Narrator | diorama · Christopher |
> | Sources | the links behind the facts |
>
> Want a change to any scene, or a new video?

## Failure handling

- Clip renders off-style / flat / glossy 3D → tighten the STYLE BLOCK and
  AVOID lines, regenerate that scene only; two identical failures = rewrite
  the prompt, not the seed.
- Generator refuses a scene → moderation. See the moderation map in the
  reference: describe figures as distant halftone cutouts with a black bar
  over the eyes, never name them; swap flagged imagery, keep the idea.
- Some platforms push a photoreal/"3D render" preset on stylized prompts —
  tell the user to decline it.
- Assembly complains → a file is missing or misnamed in `clips/` or
  `voice/`; fix, rerun the script.

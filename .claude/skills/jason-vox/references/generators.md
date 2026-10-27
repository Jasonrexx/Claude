# Generators — how scenes and the style key get made

The user picks one generator at Stage 2. The script, voice, prompts, clip
naming (`clips/block0k.mp4`), narration and cut are identical for all three.

| Generator | Who runs the generations | Images | Clips |
|---|---|---|---|
| `jason` | The assistant, automatic | Higgsfield (GPT Image 2) | Higgsfield video model |
| `flow` | The assistant, automatic, driving Google Flow in the user's Chrome | Nano Banana Pro in Flow | Gemini Omni Flash in Flow |
| `manual` | The user, any platform (Flow, Higgsfield, Veo, Kling…) | Nano Banana Pro (or any) | Gemini Omni Flash (or any) |

Aspect: generate at the user's ratio (`16:9` or `9:16`). For `4:5` and
`1:1`, generate vertical `9:16` with the action centered, and the cut crops
it (`FINAL_ASPECT`).

## Spend gate (automatic modes only)

Never generate anything until the user has approved the spend. Before the
first generation, send one short message:

> **⚡ Ready to run automatically**
>
> | | |
> |---|---|
> | Generator | `jason` (Higgsfield) *or* `flow` (Google Flow, your Plus credits) |
> | Scenes | N × 10s |
> | Estimated cost | `jason`: check balance first · `flow`: about 15 credits per 10s clip at 720p, N × 15 total (Plus has 200 a month) |
>
> Say `run` to start, or `manual` to do it yourself.

STOP and wait for `run`. If the balance or credits look too low for the
whole video, say so plainly and offer `manual` or fewer scenes. Never top
up, upgrade, or buy anything.

## `jason` — Higgsfield (automatic)

Tools: the Higgsfield MCP (`generate_image`, `generate_video`,
`jobs_wait`, `balance`, `models_explore`). Load them via ToolSearch if
deferred.

1. `balance` first. Report credits only if too low.
2. Style key: the house `assets/style-reference.png` is uploaded as the
   reference (`media_upload`). If the user chose `fresh`, generate the
   style sheet from `references/style-sheet-regeneration-prompt.txt`
   with `generate_image` (GPT Image 2, the video's aspect).
3. Each scene: `generate_video` with the scene prompt, the style key as
   reference image, the video's aspect, 10s duration, sound ON. Use
   `models_explore` to find Gemini Omni Flash and confirm it accepts 10s;
   if not, pick the closest 10s-capable model and say which, once.
4. `jobs_wait`, then download the result with `curl -o
   projects/<slug>/clips/block0k.mp4`.
5. Real people: no names in video prompts; distant halftone cutouts with
   black eye bars (see `jason-prompts.md`). If a scene is refused,
   rewrite it more indirectly and retry once or twice, then tell the user.

## `flow` — Google Flow in the user's Chrome (automatic)

Tools: a browser-control tool for the user's Chrome (in Claude this is Claude in Chrome; in Codex use its browser or computer-use tool; if none is available, offer `manual`) (`tabs_context_mcp`, `navigate`, `read_page`,
`find`, `computer`, `file_upload`, `get_page_text`). Load them in one
ToolSearch call if deferred. The user's own Chrome, signed in to their
Google account, is the only browser used.

Flow's interface changes. Never rely on remembered button positions:
read the page (`read_page` / `find` / a screenshot) before every click.

**Seen on the user's account (Plus, Oct 2026):** the home page lists
projects with a "New project" tile. Inside a project, the left rail has
All media, Characters, Scenes, Tools; a right-hand **agent panel** has a
prompt box (+ to attach, a settings icon, a send arrow). Agent settings
include "Confirm before generating" (default Always, which makes the
agent ask before spending credits), an image default (aspect, x1–x4,
model: **Nano Banana Pro**, Nano Banana 2, Nano Banana 2 Lite) and a video
default (16:9 or 9:16, x1–x4, model **Omni 1.1 Flash**). Both required
models are on Plus. Do not change the user's saved defaults; set the
model and aspect for the current generation instead, or leave the
settings panel untouched and pick them in the generation controls.
Keep "Confirm before generating" on, since Flow's own confirmation is a
second safety check on top of our spend gate; confirm it ourselves only
after the user has said `run`. Flow also grants extra daily credits on
Plus, so the credit counter is the source of truth.

**Setup (once per run)**
1. Open a new tab, go to `https://flow.google.com/`. If a sign-in or
   verification screen appears, STOP and ask the user to sign in
   themselves; never type credentials. Pages can load slowly; wait and retry.
2. Open or create a Flow project named after the video slug.
3. Confirm the pickers offer **Omni 1.1 Flash** (video) and
   **Nano Banana Pro** (image). If a model is missing on the user's plan,
   say so and offer `manual` or the closest listed model, with approval.
4. Read the credit counter if shown, compare to the estimate, then tell
   the user only if it's short.

**Style key**
- `house`: upload `assets/style-reference.png` into the project (use
  `file_upload` on the file input found via `find`; never click the file
  picker). Use it as the reference for every clip.
- `fresh`: generate the style sheet with Nano Banana Pro, using the
  prompt from `style-sheet-regeneration-prompt.txt`, aspect = the video's.

**Calibration scene (always first)**
Run scene 1 alone, end to end, and check the result with the user only if
it failed or looks off-style. Its settings (model, aspect, 10s, 720p,
reference attached, sound on) are the template for every other scene.

**Each scene**
1. Start a new video generation: Gemini Omni Flash, aspect, 10s, 720p,
   attach the style key as the reference image, sound on.
2. Paste the scene prompt exactly (use `form_input`/`type`, never edit it).
3. Click Generate. Wait for it to finish (poll with a screenshot every
   ~10s; stop and report after 5 minutes without a result).
4. Download the clip. Move the newest `.mp4` from `~/Downloads` to
   `projects/<slug>/clips/block0k.mp4`, then verify the duration with
   ffprobe (about 10s).
5. One scene at a time. Don't queue several (it protects credits).

**Stop and ask the user when:** a login, captcha, verification or payment
screen appears; Flow asks to upgrade or buy credits; a model is missing;
a scene is refused twice; anything else unexpected. Never accept terms,
purchase, upgrade, or change account settings.

Close the tab you opened when the run is finished.

## `manual` — the user runs it

Hand over each scene prompt exactly as in SKILL.md Stage 7 (paste block +
settings table), the user generates in their own tool (Flow works with
their Plus credits), saves `block0k.mp4`, and brings the clips home at
Stage 8.

## Failure handling for automatic modes

- A scene fails or renders off-style: tighten STYLE/AVOID, regenerate
  that scene only. Two identical failures: rewrite the prompt.
- An automatic run stalls for any reason: offer `manual` for the
  remaining scenes. Already-saved clips stay.
- Never submit anything beyond what the user approved at the spend gate.

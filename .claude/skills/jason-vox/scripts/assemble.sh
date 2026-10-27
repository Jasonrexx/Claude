#!/usr/bin/env bash
# assemble.sh — stitch a Vox prompt-pack project into one final MP4.
#
# Layout expected inside <project_dir>:
#   clips/block01.mp4  block02.mp4 ...   one 10s clip per block, in order
#   voice/block01.wav  block02.wav ...   one voice take per block (wav/mp3/m4a)
#
# Usage:  ./assemble.sh <project_dir>
#
# Per block: the clip is paced to exactly 10s with a short held ending; the
# voice take starts 0.25s in; a long take is tempo-compressed pitch-safely
# (warning above 1.25x);
# the clip's own ambient/SFX audio is kept underneath at low volume.
# Music: if MUSIC_DIR (default: <studio>/music, else the VOX DOCS
# music folder) holds an audio file, one track is mixed under the whole video
# at low volume with a 2s end fade. No tracks = silently skipped.
# Crop: FINAL_ASPECT=4:5 or 1:1 center-crops the finished video to that
# ratio (generate the clips vertical 9:16 for these). Unset = no crop.
# Output: <project_dir>/final.mp4  (total runtime = N x 10s exactly)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${1:?usage: assemble.sh <project_dir>}"
BLOCK=10          # seconds per block
TARGET=9.7        # compress a long take toward this
VISUAL_HOLD="${VISUAL_HOLD:-0.75}"  # pause on the final visual beat; set 0 for full-speed
command -v ffmpeg >/dev/null || { echo "ffmpeg not found — install it (brew install ffmpeg)"; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe not found"; exit 1; }

read -r VISUAL_SOURCE VISUAL_SCALE < <(python3 - <<PY
hold = float("$VISUAL_HOLD")
if not 0 <= hold < 5:
    raise SystemExit("VISUAL_HOLD must be at least 0 and under 5 seconds")
source = $BLOCK - 2 * hold
paced = $BLOCK - hold
print(f"{source:.3f} {paced / source:.6f}")
PY
)

cd "$DIR"
WORK=".assemble_work"; rm -rf "$WORK"; mkdir -p "$WORK"

clips=(clips/block*.mp4)
[ -e "${clips[0]}" ] || { echo "no clips found at clips/block*.mp4"; exit 1; }

i=0
for clip in "${clips[@]}"; do
  i=$((i+1))
  n=$(printf "%02d" "$i")
  voice=$(ls voice/block${n}.* 2>/dev/null | head -1 || true)
  [ -n "$voice" ] || { echo "missing voice take for block ${n} (voice/block${n}.*)"; exit 1; }

  vdur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$voice")
  # tempo factor for long takes, pitch-safe; 1.0 for takes that fit
  af="adelay=250|250,apad"
  over=$(python3 -c "d=float('$vdur'); print(f'{d/$TARGET:.3f}' if d>$TARGET else '1.0')")
  if [ "$over" != "1.0" ]; then
    big=$(python3 -c "print(1 if float('$over')>1.25 else 0)")
    [ "$big" = "1" ] && echo "WARN block ${n}: voice ${vdur}s needs ${over}x — rewrite the line shorter"
    af="atempo=${over},adelay=250|250,apad"
  fi

  vf="[0:v]trim=duration=${VISUAL_SOURCE},setpts=PTS-STARTPTS,setpts=PTS*${VISUAL_SCALE},tpad=stop_mode=clone:stop_duration=${VISUAL_HOLD}[v]"

  # does the clip have its own audio stream?
  has_amb=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$clip" | head -1)
  if [ -n "$has_amb" ]; then
    ffmpeg -v error -y -i "$clip" -i "$voice" -t "$BLOCK" \
      -filter_complex "${vf};[0:a]volume=0.22[amb];[1:a]${af}[vo];[amb][vo]amix=inputs=2:duration=first:normalize=0[a]" \
      -map "[v]" -map "[a]" -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -c:a aac -ar 48000 \
      "$WORK/seg${n}.mp4"
  else
    ffmpeg -v error -y -i "$clip" -i "$voice" -t "$BLOCK" \
      -filter_complex "${vf};[1:a]${af}[a]" \
      -map "[v]" -map "[a]" -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -c:a aac -ar 48000 \
      "$WORK/seg${n}.mp4"
  fi
  echo "block ${n}: clip=$(basename "$clip") voice=$(basename "$voice") (${vdur}s) ok"
  echo "file 'seg${n}.mp4'" >> "$WORK/list.txt"
done

ffmpeg -v error -y -f concat -safe 0 -i "$WORK/list.txt" -c copy "$WORK/joined.mp4"

TOTAL=$((i*BLOCK))
MUSIC_DIR="${MUSIC_DIR:-}"
if [ -z "$MUSIC_DIR" ]; then
  for d in "$SCRIPT_DIR/../../../../music" "$HOME/Documents/Jason Studio/music" "/Users/jasonrexx/Documents/VOX DOCS/music"; do
    [ -d "$d" ] && MUSIC_DIR="$d" && break
  done
fi
track=""
[ -n "$MUSIC_DIR" ] && track=$(find "$MUSIC_DIR" -maxdepth 1 -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.m4a' \) | sort -R | head -1 || true)
if [ -n "$track" ]; then
  ffmpeg -v error -y -i "$WORK/joined.mp4" -stream_loop -1 -i "$track" \
    -filter_complex "[1:a]volume=0.12,afade=t=out:st=$((TOTAL-2)):d=2[m];[0:a][m]amix=inputs=2:duration=first:normalize=0[a]" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -ar 48000 -t "$TOTAL" final.mp4
  echo "music: $(basename "$track")"
else
  mv "$WORK/joined.mp4" final.mp4
  echo "music: none found, skipped"
fi

case "${FINAL_ASPECT:-}" in
  4:5) CROP="crop=trunc(min(iw\,ih*4/5)/2)*2:trunc(min(ih\,iw*5/4)/2)*2" ;;
  1:1) CROP="crop=trunc(min(iw\,ih)/2)*2:trunc(min(iw\,ih)/2)*2" ;;
  *) CROP="" ;;
esac
if [ -n "$CROP" ]; then
  ffmpeg -v error -y -i final.mp4 -vf "$CROP" -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -c:a copy "$WORK/cropped.mp4"
  mv "$WORK/cropped.mp4" final.mp4
  echo "cropped to ${FINAL_ASPECT}"
fi

rm -rf "$WORK"
echo "done → $DIR/final.mp4  ($((i*BLOCK))s, $i blocks)"

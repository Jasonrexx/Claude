#!/bin/zsh
# Pick a local Kokoro runtime without sending narration to a cloud service.
set -eu

script_dir="${0:A:h}"
beacon_runtime="/Users/jasonrexx/Library/Application Support/Beacon/LocalSpeech/.venv/bin/python"

if [[ -n "${JASON_STUDIO_KOKORO_PYTHON:-}" ]]; then
  runtime="$JASON_STUDIO_KOKORO_PYTHON"
elif [[ -x "$beacon_runtime" ]]; then
  runtime="$beacon_runtime"
else
  print -u2 "Kokoro runtime unavailable. Set JASON_STUDIO_KOKORO_PYTHON to a Python environment with kokoro-onnx and soundfile."
  exit 1
fi

exec "$runtime" "$script_dir/kokoro_voice.py" "$@"

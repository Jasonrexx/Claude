#!/usr/bin/env python3
"""Render one Jason Studio narration line with the local Kokoro voice."""

from __future__ import annotations

import argparse
import os
from pathlib import Path


DEFAULT_MODELS = Path("/Users/jasonrexx/Library/Application Support/Beacon/LocalSpeech")


def model_directory() -> Path:
    configured = os.environ.get("JASON_STUDIO_KOKORO_MODELS")
    return Path(configured).expanduser() if configured else DEFAULT_MODELS


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--text", required=True)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--voice", default="af_heart")
    parser.add_argument("--speed", default=1.0, type=float)
    args = parser.parse_args()

    folder = model_directory()
    model = folder / "kokoro-v1.0.onnx"
    voices = folder / "voices-v1.0.bin"
    if not model.is_file() or not voices.is_file():
        raise SystemExit(
            "Kokoro model files are missing. Set JASON_STUDIO_KOKORO_MODELS to "
            "the folder containing kokoro-v1.0.onnx and voices-v1.0.bin."
        )

    from kokoro_onnx import Kokoro
    import soundfile as sf

    args.output.parent.mkdir(parents=True, exist_ok=True)
    engine = Kokoro(str(model), str(voices))
    samples, rate = engine.create(
        args.text, voice=args.voice, speed=args.speed, lang="en-us"
    )
    sf.write(args.output, samples, rate, format="WAV", subtype="PCM_16")


if __name__ == "__main__":
    main()

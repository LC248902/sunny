"""
test_vlm_images.py — Batch-test a folder of images against an MLX VLM model.

Run on your Mac:
    python test_vlm_images.py

Requires:
    pip install mlx-vlm

Edit the config variables below before running.
"""

import json
import os
import time
import glob
from pathlib import Path

from mlx_vlm import load, generate

# ── Config ───────────────────────────────────────────────────────────────────
MLX_MODEL_FOLDER = "./quant-experiments/sunny-medgemma-mlx-4bit-gs32"  # HF repo or local path
IMAGE_FOLDER = "./data/test-sunscreen-photos"                                # folder of images
PROMPT = "sunscreen extract"                     # prompt sent with each image
MAX_TOKENS = 512
TEMPERATURE = 0.7
TOP_P = 0.95
REPETITION_PENALTY = 1.2
IMAGE_EXTENSIONS = (".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tiff")
# ─────────────────────────────────────────────────────────────────────────────


def get_image_paths(folder: str) -> list[str]:
    """Collect all image files from a folder (non-recursive)."""
    paths = []
    for ext in IMAGE_EXTENSIONS:
        paths.extend(glob.glob(os.path.join(folder, f"*{ext}")))
        paths.extend(glob.glob(os.path.join(folder, f"*{ext.upper()}")))
    return sorted(set(paths))


def build_prompt(text_prompt: str) -> str:
    """Build prompt with <image> BEFORE <text>, matching MedGemma training format."""
    return (
        f"<bos><start_of_turn>user\n"
        f"<start_of_image>{text_prompt}<end_of_turn>\n"
        f"<start_of_turn>model\n"
    )


def build_results_filepath(model_folder: str, image_folder: str) -> str:
    """Build output path: test_results/{model_name}_{image_folder}.json"""
    model_name = Path(model_folder).name
    image_folder_name = Path(image_folder).name
    return f"test_results/{model_name}_{image_folder_name}.json"


def main():
    # ── Resolve output path ──────────────────────────────────────────────
    results_filepath = build_results_filepath(MLX_MODEL_FOLDER, IMAGE_FOLDER)
    os.makedirs(os.path.dirname(results_filepath), exist_ok=True)

    # ── Discover images ──────────────────────────────────────────────────
    image_paths = get_image_paths(IMAGE_FOLDER)
    if not image_paths:
        print(f"No images found in '{IMAGE_FOLDER}' with extensions {IMAGE_EXTENSIONS}")
        return

    print(f"Found {len(image_paths)} image(s) in '{IMAGE_FOLDER}'")
    print(f"Model:   {MLX_MODEL_FOLDER}")
    print(f"Output:  {results_filepath}")
    print()

    # ── Load model once ──────────────────────────────────────────────────
    print("Loading model...")
    t0 = time.time()
    model, processor = load(MLX_MODEL_FOLDER)
    print(f"Model loaded in {time.time() - t0:.1f}s\n")

    # ── Build prompt (same for all images) ───────────────────────────────
    formatted_prompt = build_prompt(PROMPT)
    print("=== FULL INPUT PROMPT ===")
    print(repr(formatted_prompt))
    print("=========================\n")

    # ── Run inference on each image ──────────────────────────────────────
    results = []

    for i, image_path in enumerate(image_paths, 1):
        print(f"[{i}/{len(image_paths)}] {os.path.basename(image_path)} ... ", end="", flush=True)

        try:
            start = time.time()
            output = generate(
                model,
                processor,
                formatted_prompt,
                [image_path],
                max_tokens=MAX_TOKENS,
                temperature=TEMPERATURE,
                top_p=TOP_P,
                repetition_penalty=REPETITION_PENALTY,
                verbose=False,
            )
            elapsed = time.time() - start

            # generate() returns a string or an object with .text depending on version
            output_text = output.text if hasattr(output, "text") else str(output)
            output_text = output_text.strip()

            results.append({
                "image_path": image_path,
                "input_prompt": PROMPT,
                "input_prompt_full": formatted_prompt,
                "output": output_text,
                "time_taken": int(elapsed),
                "model_used": MLX_MODEL_FOLDER,
            })
            print(f"{int(elapsed)}s — {output_text[:80]}...")

        except Exception as e:
            print(f"ERROR: {e}")
            results.append({
                "image_path": image_path,
                "input_prompt": PROMPT,
                "input_prompt_full": formatted_prompt,
                "output": f"ERROR: {e}",
                "time_taken": 0,
                "model_used": MLX_MODEL_FOLDER,
            })

    # ── Save results ─────────────────────────────────────────────────────
    with open(results_filepath, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\nDone. {len(results)} result(s) saved to {results_filepath}")


if __name__ == "__main__":
    main()
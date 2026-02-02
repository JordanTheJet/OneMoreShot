#!/usr/bin/env python3
"""
Luma Modify-Video Test
Uses luma/modify-video for style transfer with Takehiko Inoue aesthetic.
"""

import os
import sys
import requests
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

import replicate

# Style prompts for Takehiko Inoue manga aesthetic
PROMPT_1_2 = """Transform into Takehiko Inoue manga art style from Slam Dunk and Vagabond.
Realistic manga illustration with ink wash painting influence.
Dynamic brushwork, high detail, painterly textures.
Basketball players in high school locker room, atmospheric blue-green lighting.
Red Somerville basketball jerseys, warm skin tones.
Emotional realism, dramatic lighting, manga aesthetic."""

# Paths
SCRIPT_DIR = Path(__file__).parent
VIDEO_DIR = SCRIPT_DIR.parent / "video_generation"
OUTPUT_DIR = VIDEO_DIR / "output"


def generate_video(
    video_path: str,
    prompt: str,
    output_name: str = "output.mp4",
    mode: str = "flex_2"  # flex modes give more stylistic change
):
    """
    Generate styled video using Luma modify-video.

    Modes:
    - adhere_1/2/3: subtle changes, close to source
    - flex_1/2/3: stylistic changes while keeping recognizable elements
    - reimagine_1/2/3: dramatic transformation, loosely follows source
    """
    print(f"\n{'='*60}")
    print("Luma Modify-Video - Style Transfer")
    print(f"{'='*60}")
    print(f"Input Video: {video_path}")
    print(f"Mode: {mode}")
    print(f"\nPrompt:\n{prompt[:200]}...")
    print(f"{'='*60}\n")

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Starting Luma video modification...")

    try:
        with open(video_path, "rb") as vid_file:
            output = replicate.run(
                "luma/modify-video",
                input={
                    "video": vid_file,
                    "prompt": prompt,
                    "mode": mode,
                }
            )

        # Get output URL
        if isinstance(output, str):
            video_url = output
        elif hasattr(output, 'url'):
            video_url = output.url
        else:
            video_url = str(output)

        print(f"\nGenerated video URL: {video_url}")

        # Download
        print("Downloading generated video...")
        response = requests.get(video_url)
        response.raise_for_status()

        output_path = OUTPUT_DIR / output_name
        with open(output_path, "wb") as f:
            f.write(response.content)

        print(f"Saved to: {output_path}")
        return str(output_path)

    except Exception as e:
        print(f"Error generating video: {e}")
        import traceback
        traceback.print_exc()
        return None


def main():
    # Input video - 1.2.MOV (teammates walking, 8.7s)
    input_video = VIDEO_DIR / "1.2.MOV"

    if not input_video.exists():
        print(f"Error: Video not found: {input_video}")
        sys.exit(1)

    file_size_mb = input_video.stat().st_size / (1024*1024)
    print(f"Input video: {input_video}")
    print(f"  Size: {file_size_mb:.1f} MB")

    if file_size_mb > 100:
        print("Warning: Video exceeds 100MB limit!")

    # Generate video with flex_2 mode (stylistic but recognizable)
    result = generate_video(
        video_path=str(input_video),
        prompt=PROMPT_1_2,
        output_name="scene1_2_luma_flex2.mp4",
        mode="flex_2"
    )

    if result:
        print(f"\nSuccess! Output: {result}")
    else:
        print("\nFailed to generate video.")
        sys.exit(1)


if __name__ == "__main__":
    main()

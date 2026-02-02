#!/usr/bin/env python3
"""
Kling v2.6 Motion Control - Video-to-Video Test
Uses reference video for motion + Takehiko Inoue style prompt.

Usage:
    python kling_video_test.py
"""

import os
import sys
import requests
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

import replicate

# Style prompts
STYLE_BASE = """Takehiko Inoue art style, late Slam Dunk and Vagabond aesthetic,
realistic manga illustration, ink wash painting influence, emotional realism,
dynamic brushwork, high detail, dramatic lighting, painterly textures"""

STYLE_CHARACTER = """Takehiko Inoue character style, realistic proportions, expressive but subtle,
Black American teenage boy, natural hair texture, warm skin tones,
wearing red Somerville basketball jersey, Slam Dunk manga aesthetic"""

# Scene 3.3 prompt - Jeffrey with balloon at dinner
PROMPT_3_3 = f"""Young Black teenage boy (Jeffrey, 14 years old) seated at dining table,
warm evening lighting, birthday celebration. Wearing casual clothes.
Relaxed, happy expression, looking at camera with easy affection.
Single balloon floating nearby. Modest apartment dining room background.
Tender, ordinary, precious family moment.

{STYLE_CHARACTER}

{STYLE_BASE}"""

# Paths
SCRIPT_DIR = Path(__file__).parent
VIDEO_DIR = SCRIPT_DIR.parent / "video_generation"
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "sprites"
OUTPUT_DIR = VIDEO_DIR / "output"


def generate_video(
    reference_image_path: str,
    reference_video_path: str,
    prompt: str,
    output_name: str = "output.mp4",
    mode: str = "std"
):
    """
    Generate styled video using Kling v2.6 motion control.
    """
    print(f"\n{'='*60}")
    print("Kling v2.6 Motion Control - Video Generation")
    print(f"{'='*60}")
    print(f"Reference Image: {reference_image_path}")
    print(f"Reference Video: {reference_video_path}")
    print(f"Mode: {mode}")
    print(f"\nPrompt:\n{prompt[:300]}...")
    print(f"{'='*60}\n")

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Starting Kling video generation...")

    try:
        with open(reference_image_path, "rb") as img_file, \
             open(reference_video_path, "rb") as vid_file:

            output = replicate.run(
                "kwaivgi/kling-v2.6-motion-control",
                input={
                    "image": img_file,
                    "video": vid_file,
                    "prompt": prompt,
                    "mode": mode,
                    "character_orientation": "video",
                    "keep_original_sound": False,
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
    # Reference image - use the panel 3.3 generated image or jersey reference
    reference_image = ASSETS_DIR / "scene3" / "panel3_jeffrey_balloon" / "background.png"

    # Fallback to jersey reference if panel image doesn't exist
    if not reference_image.exists():
        reference_image = SCRIPT_DIR / "marcus-jersey.jpg"

    # Reference video - 3.3.MOV (Jeffrey with balloon, 7s)
    reference_video = VIDEO_DIR / "3.3.MOV"

    # Verify files exist
    if not reference_image.exists():
        print(f"Error: Reference image not found: {reference_image}")
        sys.exit(1)

    if not reference_video.exists():
        print(f"Error: Reference video not found: {reference_video}")
        sys.exit(1)

    print(f"Reference image: {reference_image}")
    print(f"  Size: {reference_image.stat().st_size / 1024:.1f} KB")
    print(f"Reference video: {reference_video}")
    print(f"  Size: {reference_video.stat().st_size / (1024*1024):.1f} MB")

    # Generate video
    result = generate_video(
        reference_image_path=str(reference_image),
        reference_video_path=str(reference_video),
        prompt=PROMPT_3_3,
        output_name="scene3_3_test.mp4",
        mode="std"
    )

    if result:
        print(f"\nSuccess! Output: {result}")
    else:
        print("\nFailed to generate video.")
        sys.exit(1)


if __name__ == "__main__":
    main()

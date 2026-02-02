#!/usr/bin/env python3
"""
AnimateDiff Vid2Vid Test
Uses lucataco/animate-diff-vid2vid to stylize video with Takehiko Inoue aesthetic.
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
wearing red Somerville high school basketball jersey, Slam Dunk manga aesthetic"""

# Scene 1.2 prompt - Teammates walking past in locker room
PROMPT_1_2 = f"""Basketball players walking through locker room corridor,
silhouettes backlit by bright doorway light, atmospheric moody lighting,
blue-green fluorescent tones, steam and dust particles in air,
high school locker room setting, athletic builds in warm-up gear.

{STYLE_CHARACTER}

{STYLE_BASE}"""

NEGATIVE_PROMPT = """3D render, photorealistic western cartoon, chibi, cute style,
exaggerated expressions, text, watermark, signature, UI elements, blurry,
low quality, oversaturated colors, anime eyes, cartoon style"""

# Paths
SCRIPT_DIR = Path(__file__).parent
VIDEO_DIR = SCRIPT_DIR.parent / "video_generation"
OUTPUT_DIR = VIDEO_DIR / "output"


def generate_video(
    video_path: str,
    prompt: str,
    output_name: str = "output.mp4",
    strength: float = 0.6,
    guidance_scale: float = 7.5,
    num_steps: int = 25
):
    """
    Generate styled video using AnimateDiff vid2vid.
    """
    print(f"\n{'='*60}")
    print("AnimateDiff Vid2Vid - Video Stylization")
    print(f"{'='*60}")
    print(f"Input Video: {video_path}")
    print(f"Strength: {strength}")
    print(f"Guidance Scale: {guidance_scale}")
    print(f"Steps: {num_steps}")
    print(f"\nPrompt:\n{prompt[:200]}...")
    print(f"{'='*60}\n")

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Starting AnimateDiff video generation...")

    try:
        with open(video_path, "rb") as vid_file:
            output = replicate.run(
                "lucataco/animate-diff-vid2vid",
                input={
                    "video": vid_file,
                    "prompt": prompt,
                    "negative_prompt": NEGATIVE_PROMPT,
                    "strength": strength,
                    "guidance_scale": guidance_scale,
                    "num_inference_steps": num_steps,
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

    print(f"Input video: {input_video}")
    print(f"  Size: {input_video.stat().st_size / (1024*1024):.1f} MB")

    # Generate video
    result = generate_video(
        video_path=str(input_video),
        prompt=PROMPT_1_2,
        output_name="scene1_2_animatediff.mp4",
        strength=0.6,  # Higher = more stylization, lower = more original
        guidance_scale=7.5,
        num_steps=25
    )

    if result:
        print(f"\nSuccess! Output: {result}")
    else:
        print("\nFailed to generate video.")
        sys.exit(1)


if __name__ == "__main__":
    main()

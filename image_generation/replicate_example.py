#!/usr/bin/env python3
"""
One More Shot - Image Generation Script
Uses Replicate's Flux model to generate panel images for the game.

Usage:
    python replicate_example.py                    # Generate all panels
    python replicate_example.py --scene 1          # Generate only Scene 1
    python replicate_example.py --panel 1.4        # Generate specific panel
    python replicate_example.py --dry-run          # Show prompts without generating
"""

import os
import argparse
import requests
import time
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

import replicate

# Output directory for generated images
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "sprites"

# Style consistency additions (from video-prompts-one-more-shot.md)
STYLE_BASE = """Takehiko Inoue art style, late Slam Dunk and Vagabond aesthetic,
realistic manga illustration, ink wash painting influence, emotional realism,
dynamic brushwork, high detail, dramatic lighting, painterly textures"""

STYLE_CHARACTER = """Takehiko Inoue character style, realistic proportions, expressive but subtle,
same face across all shots, Black American features, natural
hair texture, warm skin tones, Slam Dunk manga aesthetic"""

STYLE_FIRST_PERSON = """Subjective camera, looking through someone's eyes, camera IS the viewer's eyes,
no body visible in frame except hands when specified, immersive first-person point of view,
what the character sees, Takehiko Inoue ink wash backgrounds"""

NEGATIVE_PROMPT = """3D render, photorealistic, western cartoon, chibi, cute style,
exaggerated expressions, speed lines, text, watermark, signature,
UI elements, blurry, low quality, oversaturated colors, third person view,
showing full body, external camera angle, observer perspective"""

# Panel definitions following video-prompts-one-more-shot.md
PANELS = {
    # Scene 1: Locker Room
    "1.1": {
        "name": "wide_locker",
        "description": "Wide Locker Room",
        "prompt": """Subjective camera view through someone's eyes, sitting on wooden bench in dim high school locker room.
Looking down at polished concrete floor between my feet. Metal lockers line the walls on both sides.
Fluorescent lights overhead cast cold blue-green light. Steam wisps drift across view.
Dust particles float in light shafts. The viewer IS the camera - no body visible.
Moody, anticipatory atmosphere. Takehiko Inoue style, ink wash aesthetic, cinematic.""",
        "style": STYLE_FIRST_PERSON,
    },
    "1.2": {
        "name": "teammates",
        "description": "Teammates Walking Past",
        "prompt": """Subjective camera through someone's eyes sitting on bench, looking up at teammates walking past.
Three to four basketball player silhouettes walk from left to right across my field of vision,
backlit by bright doorway at end of corridor. Players are dark shapes against the light,
athletic builds in warm-up gear. The viewer IS the camera - no body visible.
Fluorescent light overhead, steam in background. Takehiko Inoue style, ink wash, atmospheric.""",
        "style": STYLE_FIRST_PERSON,
    },
    "1.3": {
        "name": "doorway_toss",
        "description": "Teammate at Doorway Tosses Ball",
        "prompt": """Subjective camera through my eyes in dark locker room, looking toward bright doorway ahead.
A teenage boy silhouette (Jeffrey, 14 years old) stands in doorway, backlit by warm gymnasium light.
He turns toward me, holding basketball ready to toss underhand in my direction.
The viewer IS the camera - I am looking at him from the bench. No body visible.
Dramatic lighting contrast between dark locker room and bright doorway.
Takehiko Inoue style, cinematic composition.""",
        "style": STYLE_FIRST_PERSON,
    },
    "1.4": {
        "name": "ball_catch",
        "description": "Ball Approaching + CATCH",
        "prompt": """Subjective camera through my eyes, basketball flying toward me through the air.
The ball approaches in gentle arc, growing larger as it comes closer to my face.
Background is blurred locker room with bright doorway behind. Ball rotates slowly, leather texture visible.
Shallow depth of field. My own hands visible at bottom of frame reaching up to catch,
wristband on left wrist. The viewer IS the camera catching this ball.
Takehiko Inoue style, soft lighting, intimate moment.""",
        "style": STYLE_FIRST_PERSON,
    },

    # Scene 2: Outdoor Court
    "2.1": {
        "name": "court_wide",
        "description": "Wide Court, Golden Hour",
        "prompt": """Wide establishing shot of urban basketball court at golden hour,
Boston neighborhood. Cracked asphalt court with faded paint lines, chain-link
fence surrounding, distant triple-decker houses visible beyond. Late summer
afternoon, warm orange sunlight, long shadows. Lens flare from setting sun.
Old tournament flyers on fence. Heat shimmer rising from asphalt. Leaves drift.
No people in frame. Nostalgic, warm, peaceful. Takehiko Inoue style,
late Slam Dunk aesthetic, painterly backgrounds.""",
        "style": STYLE_BASE,
    },
    "2.2": {
        "name": "jeffrey_rest",
        "description": "Jeffrey Catching Breath",
        "prompt": """Medium shot of young Black teenage boy (Jeffrey, 14 years old) in basketball clothes
standing under basketball hoop on outdoor court, hands on knees, catching
breath. Golden hour lighting from behind creates rim light on shoulders
and head. Wearing sleeveless jersey, shorts, wristband visible on
left wrist. Sweat glistening on skin. Chest heaving with breath.
Expression is tired but content. Chain-link fence and houses soft in background.
Takehiko Inoue style, warm colors, painterly.""",
        "style": STYLE_CHARACTER,
    },
    "2.3": {
        "name": "jeffrey_grin",
        "description": "Jeffrey Grins, Gestures One More",
        "prompt": """Medium shot of young Black teenage boy (Jeffrey, 14 years old) on outdoor basketball court
at golden hour. He stands up straight, wipes sweat from forehead,
breaks into confident easy grin. Makes casual hand gesture - holds up one finger,
"one more" - while looking directly at camera with warm challenging expression.
Wristband visible. Golden backlight creates glow around him. Charismatic,
big brother energy. Takehiko Inoue style, expressive face, warm tones.""",
        "style": STYLE_CHARACTER,
    },
    "2.4": {
        "name": "jeffrey_ready",
        "description": "Jeffrey Sets Position + PASS",
        "prompt": """Medium-wide shot of young Black teenage boy (Jeffrey, 14 years old) on outdoor basketball
court in ready position to receive pass. Near three-point line, knees bent,
hands up and ready, eyes locked on camera with focused intensity. Waiting.
Golden hour light, long shadows on asphalt. Athletic anticipation stance.
Player's hands visible in foreground holding basketball, wristband on left wrist,
ready to pass. Takehiko Inoue style, dynamic pose, warm lighting.""",
        "style": STYLE_CHARACTER,
    },
    "2.5": {
        "name": "jeffrey_shot",
        "description": "The Shot - Jeffrey catches and shoots",
        "prompt": """Outdoor basketball court, golden hour. Young Black teenage boy (Jeffrey, 14)
at peak of jump shot, perfect shooting form, releasing basketball toward hoop.
Ball in mid-air trajectory toward basket. Triumphant moment. Wristband visible.
Golden light behind him, almost haloed. Championship banner feeling.
Takehiko Inoue style, fluid motion captured, emotional peak moment. Dynamic composition.""",
        "style": STYLE_CHARACTER,
    },

    # Scene 3: Dining Room
    "3.1": {
        "name": "table_wide",
        "description": "Table Wide Shot",
        "prompt": """Subjective camera through my eyes seated at dining table, looking across at birthday cake.
Evening light, warm overhead lamp casts golden glow on wooden table in front of me.
Birthday cake with "14" candles (just blown out, smoke wisps rising) sits at center.
Three place settings visible. Window shows evening blue outside. The viewer IS the camera.
No body visible. Single balloon floats at edge of my vision. Cozy Boston apartment.
Takehiko Inoue style, warm palette, intimate domestic moment.""",
        "style": STYLE_FIRST_PERSON,
    },
    "3.2": {
        "name": "mom_face",
        "description": "Mom's Face",
        "prompt": """Medium close-up of Black woman (Mrs. Cole, early 40s) seated at dinner table,
warm overhead lighting. Tired but genuinely happy expression, soft
smile watching something off-camera (her sons). Modest clothing,
end of a long workday but present for this moment. Eyes warm with
love, slight head tilt. Background soft, out of focus warm tones.
Takehiko Inoue style, gentle expression, warm intimate lighting.""",
        "style": STYLE_CHARACTER,
    },
    "3.3": {
        "name": "jeffrey_balloon",
        "description": "Jeffrey with Balloon + BALLOON PASS",
        "prompt": """Medium shot of young Black teenage boy (Jeffrey, 14) seated at dinner table, warm
evening lighting. Wearing casual clothes, wristband visible on
wrist resting on table. Relaxed, happy, watching camera (his little
brother Marcus) with easy affection. Single balloon floats nearby at edge
of frame, drifting gently. Background shows modest apartment dining room,
birthday cake remnants. Tender, ordinary, precious moment.
Player's hands visible at bottom, at table level. Takehiko Inoue style, warm palette.""",
        "style": STYLE_CHARACTER,
    },
    "3.4": {
        "name": "expression_shift",
        "description": "Jeffrey Catches Balloon, Expression Shift",
        "prompt": """Medium shot of young Black teenage boy (Jeffrey, 14) at dinner table holding a balloon.
His expression is deep, serious, looking directly at camera with knowing intensity.
Eyes say everything. Tender, bittersweet, profound moment.
Image has slight overexposure bloom effect, dreamy quality, fading to white at edges.
Wristband visible. Takehiko Inoue style, emotional character moment,
gradual white fade feeling around the edges.""",
        "style": STYLE_CHARACTER,
    },

    # Scene 4: Championship
    "4.1": {
        "name": "court_lights",
        "description": "White Resolves to Court Lights",
        "prompt": """Subjective camera through my eyes looking straight up at gymnasium ceiling.
Bright ceiling lights directly above, multiple light fixtures in geometric pattern.
Lens flare and bloom from the intensity. Industrial ceiling, championship banners at edges of vision.
The viewer IS the camera - I am looking up. Bright, overwhelming, dramatic.
Slight overexposure effect. Takehiko Inoue style, dramatic lighting.""",
        "style": STYLE_BASE,
    },
    "4.2": {
        "name": "wristband",
        "description": "Wristband Close-up",
        "prompt": """Subjective camera through my eyes looking down at my own left wrist.
My forearm extends into frame, the wristband (Jeffrey's wristband) visible on my wrist.
Fabric texture visible, slightly worn with love. Background is blurred polished wooden
basketball court floor. The viewer IS the camera - this is my arm, my wrist.
Bright gymnasium lighting. Intimate, weighted moment. Takehiko Inoue style,
shallow depth of field, emotional focus on wristband.""",
        "style": STYLE_FIRST_PERSON,
    },
    "4.3": {
        "name": "face_court",
        "description": "Camera Rises to Face Court - Championship",
        "prompt": """Subjective camera through my eyes facing forward across championship basketball court.
I am standing on the court looking toward the far basket. Polished wood floor with court lines ahead.
Crowd in bleachers as impressionistic blur of color on both sides of my vision.
Teammates visible in my periphery as soft shapes. The viewer IS the camera - I am about to shoot.
Bright overhead lights. No body visible. Takehiko Inoue style, dramatic composition, triumphant feeling.
Vignette at edges.""",
        "style": STYLE_FIRST_PERSON,
    },
}


def build_full_prompt(panel_data: dict) -> str:
    """Combine panel prompt with style modifiers."""
    prompt = panel_data["prompt"].strip()
    style = panel_data.get("style", STYLE_BASE).strip()

    full_prompt = f"{prompt}\n\n{style}\n\n{STYLE_BASE}"
    return full_prompt


def generate_image(panel_id: str, panel_data: dict, dry_run: bool = False) -> str | None:
    """Generate an image for a panel using Replicate's Flux model."""

    prompt = build_full_prompt(panel_data)

    scene_num = panel_id.split(".")[0]
    panel_num = panel_id.split(".")[1]
    scene_dir = OUTPUT_DIR / f"scene{scene_num}" / f"panel{panel_num}_{panel_data['name']}"

    print(f"\n{'='*60}")
    print(f"Panel {panel_id}: {panel_data['description']}")
    print(f"Output: {scene_dir}")
    print(f"{'='*60}")

    if dry_run:
        print(f"\n[DRY RUN] Prompt:\n{prompt[:500]}...")
        return None

    # Create output directory
    scene_dir.mkdir(parents=True, exist_ok=True)

    print(f"\nGenerating image...")

    try:
        output = replicate.run(
            "black-forest-labs/flux-dev",
            input={
                "prompt": prompt,
                "negative_prompt": NEGATIVE_PROMPT,
                "num_inference_steps": 28,
                "guidance_scale": 7.5,
                "width": 1920,
                "height": 1080,
                "num_outputs": 1,
            }
        )

        # Get the image URL
        if isinstance(output, list) and len(output) > 0:
            image_url = str(output[0])
        else:
            image_url = str(output)

        print(f"Generated: {image_url}")

        # Download the image
        response = requests.get(image_url)
        response.raise_for_status()

        # Save as background.png (primary layer)
        output_path = scene_dir / "background.png"
        with open(output_path, "wb") as f:
            f.write(response.content)

        print(f"Saved to: {output_path}")
        return str(output_path)

    except Exception as e:
        print(f"Error generating image: {e}")
        return None


def main():
    parser = argparse.ArgumentParser(description="Generate panel images for One More Shot")
    parser.add_argument("--scene", type=int, help="Generate only specific scene (1-4)")
    parser.add_argument("--panel", type=str, help="Generate only specific panel (e.g., 1.4)")
    parser.add_argument("--dry-run", action="store_true", help="Show prompts without generating")
    parser.add_argument("--list", action="store_true", help="List all panels")
    args = parser.parse_args()

    if args.list:
        print("Available panels:\n")
        for panel_id, data in PANELS.items():
            print(f"  {panel_id}: {data['description']}")
        return

    # Filter panels based on arguments
    panels_to_generate = {}

    if args.panel:
        if args.panel in PANELS:
            panels_to_generate[args.panel] = PANELS[args.panel]
        else:
            print(f"Panel {args.panel} not found. Use --list to see available panels.")
            return
    elif args.scene:
        for panel_id, data in PANELS.items():
            if panel_id.startswith(f"{args.scene}."):
                panels_to_generate[panel_id] = data
        if not panels_to_generate:
            print(f"No panels found for scene {args.scene}")
            return
    else:
        panels_to_generate = PANELS

    print(f"One More Shot - Image Generation")
    print(f"{'='*60}")
    print(f"Generating {len(panels_to_generate)} panels")
    print(f"Output directory: {OUTPUT_DIR}")

    if args.dry_run:
        print("\n[DRY RUN MODE - No images will be generated]\n")

    # Generate images
    results = []
    panel_ids = sorted(panels_to_generate.keys(), key=lambda x: (int(x.split(".")[0]), int(x.split(".")[1])))
    for i, panel_id in enumerate(panel_ids):
        panel_data = panels_to_generate[panel_id]
        result = generate_image(panel_id, panel_data, dry_run=args.dry_run)
        results.append((panel_id, result))

        # Rate limit delay (skip for last panel and dry runs)
        if not args.dry_run and i < len(panel_ids) - 1:
            print("\nWaiting 10 seconds for rate limit...")
            time.sleep(10)

    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")

    successful = [r for r in results if r[1] is not None]
    failed = [r for r in results if r[1] is None and not args.dry_run]

    if args.dry_run:
        print(f"Dry run complete. {len(results)} panels would be generated.")
    else:
        print(f"Generated: {len(successful)}/{len(results)} panels")

        if failed:
            print(f"\nFailed panels:")
            for panel_id, _ in failed:
                print(f"  - {panel_id}: {PANELS[panel_id]['description']}")


if __name__ == "__main__":
    main()

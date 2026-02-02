# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**One More Shot** - A Godot 4.5 narrative game with MediaPipe hand gesture controls for Global Game Jam 2026. Players relive memories as Marcus Cole through gesture-based interactions across 4 scenes (16 panels total).

## Running the Project

### 1. Start Python Hand Tracking Server
```bash
cd python
source .venv/bin/activate  # Create with: python3 -m venv .venv && pip install -r requirements.txt
python hand_tracker.py --port 8765 --camera 0 --show-preview
```

### 2. Run Godot Project
Open in Godot 4.5 and press F5, or:
```bash
godot --path .
```

### Debug Controls (in-game)
- **Space**: Advance to next panel
- **Escape**: Skip to next scene
- **R**: Restart game

## Architecture

### Autoloads (Global Singletons)
- **GameManager**: Scene sequencing, game state (PLAYING → TRANSITIONING → ENDED)
- **TransitionManager**: Scene transitions (DISSOLVE, FADE_WHITE, FADE_BLACK)
- **AudioManager**: Music/SFX with crossfade support
- **GestureDetector**: Converts MediaPipe data to game interactions

### Signal Flow
```
Python hand_tracker.py (WebSocket :8765)
    ↓ JSON landmarks + gestures
HandTracking.gd (WebSocket client)
    ↓ landmarks_received signal
GestureDetector.gd (gesture recognition)
    ↓ gesture_detected signal
PanelController.gd (per-scene, advances panels)
    ↓ scene_completed signal
GameManager.gd (loads next scene)
```

### Gesture Detection Logic
```gdscript
# In gesture_detector.gd - uses MediaPipe's built-in gesture recognition
if two_open_palms:
    detected_type = InteractionType.CATCH      # Both hands open
elif has_open_palm:
    if expected_gesture == InteractionType.BALLOON:
        detected_type = InteractionType.BALLOON  # Single palm (dining scene)
    else:
        detected_type = InteractionType.PASS     # Single palm (court scene)
```
All gestures require 0.5s hold time to confirm.

### Panel System
Each scene contains a `PanelController` managing horizontal panel strip with camera panning. Panels are defined in scene scripts (e.g., `scene1_locker.gd`) using `PanelData` resources:
- `duration`: Auto-advance time (0 = wait for interaction)
- `interaction_type`: NONE, CATCH, PASS, or BALLOON
- `fallback_timeout`: Auto-advance after 15s if no gesture

### Scene Structure
| Scene | Panels | Interaction |
|-------|--------|-------------|
| 1: Locker Room | 4 | CATCH (panel 4) |
| 2: Outdoor Court | 5 | PASS (panel 4) |
| 3: Dining Room | 4 | BALLOON (panel 3) |
| 4: Championship | 3 | None (resolution) |

## Key Files

- `scripts/core/panel_controller.gd` - Main panel navigation, UI, gesture handling
- `scripts/core/game_manager.gd` - Scene sequencing
- `scripts/input/gesture_detector.gd` - Gesture recognition from MediaPipe data
- `scripts/input/hand_tracking.gd` - WebSocket client for Python bridge
- `python/hand_tracker.py` - MediaPipe GestureRecognizer → WebSocket server

## Image Generation

Generate panel images with Replicate Flux API:
```bash
cd image_generation
source .venv/bin/activate
python replicate_example.py --panel 2.4  # Single panel
python replicate_example.py --scene 1    # Entire scene
python replicate_example.py --dry-run    # Preview prompts
```

Style: Takehiko Inoue (Slam Dunk/Vagabond) ink wash aesthetic.

## Display Settings

- Viewport: 1024x1224 (1024 for panel image + 200 for bottom UI bar)
- Panel images: 1024px wide
- Bottom bar shows gesture hints during interactions

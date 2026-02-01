# One More Shot
## Product Requirements Document

**Version:** 1.2 (Scoped for Jam, Original IP)  
**Last Updated:** January 2025  
**Project Type:** Game Jam — Narrative Experience  
**Engine:** Godot 4.x  

---

## Overview

One More Shot is a first-person narrative experience where players embody **Marcus Cole**, a high school point guard about to play the biggest game of his life. Through simple motion-controlled gestures, players relive memories of his late brother **Jeffrey Cole** — a basketball prodigy taken too soon. Set in Boston.

**Scoped Experience:** 4 scenes, 16 panels, 3 interactions, ~2-3 minutes

**Core Design Pillars:**
- The mechanic is the meaning — every gesture carries emotional weight
- No dialogue (except one whispered line) — music and motion tell the story
- The loss is felt, not shown — implication over exposition

---

## Characters

**Marcus Cole (Player Character)**
- 17 years old, junior point guard at a Boston public high school
- Quiet, focused, carries weight he doesn't talk about
- Wears his brother's wristband — never takes it off
- This championship game is his chance to honor Jeffrey's memory

**Jeffrey Cole (Brother)**
- Would be 18 now, but died at 14 — just before starting high school
- Was already the best player the neighborhood had ever seen — everyone said he was going places
- Confident but never arrogant, always made time for his little brother
- Taught Marcus everything about the game in their short time together

**D (Best Friend)**
- Marcus's closest friend and teammate
- Knew Jeffrey too — understands what this game means
- On the court with Marcus in Scene 4, passes him the ball before the final shot
- A look of understanding between them — no words needed

**Ma (Mother)**
- Single mom, works long hours
- Present in the dining room scene — tired but proud of her boys
- Peripheral presence — this story is about the brothers

---

## Narrative Structure

### Scene 1: Locker Room (Present)

**Setting:** Dimly lit locker room. Wooden benches, metal lockers, fluorescent hum. Steam lingers. Boston high school — nothing fancy, but it's home.

**Sequence:**
1. Fade in. First-person view, seated on bench, head slightly down
2. Teammates walk past in the background (silhouettes or partial figures)
3. Final teammate stops at the doorway, turns
4. Ball is tossed toward camera in a gentle arc
5. **INTERACTION: Raise hands to catch**
6. Ball lands in hands. Beat of stillness.
7. Camera drifts down to wristband on left wrist — Jeffrey's wristband — then to the ball's texture
8. Audio shifts — present-day ambient fades, replaced by outdoor ambiance
9. Dissolve to Scene 2

**Emotional Beat:** Trust. Acceptance. "It's time."

---

### Scene 2: Outdoor Court (Flashback — Childhood)

**Setting:** Golden hour. Cracked asphalt court at a Dorchester park. Chain-link fence, distant traffic, summer heat. Faded tournament flyers on the fence — Jeffrey's name still visible on the old ones.

**Context:** Jeffrey (13-14 in this memory) was already the best player the neighborhood had seen. Everyone knew he was going places. Marcus (10 here) idolizes his big brother. This is where Marcus learned everything.

**Sequence:**
1. Fade in. First-person, standing at the three-point line
2. Jeffrey stands under the basket, hands on knees, catching breath — even exhausted, his form is perfect
3. He straightens up, wipes sweat, grins at camera with easy confidence
4. He gestures — one more
5. He moves to his spot with practiced grace, waiting for the pass
6. **INTERACTION: Push forward to pass the ball**
7. Ball arcs through the air toward Jeffrey
8. He catches — footwork, elevation, release. Textbook.
9. Ball swishes through the net. Nothing but net.
10. Jeffrey turns back to camera, smiles, points at you — *your turn someday*
11. Hold on his face, golden light behind him
12. Slow dissolve — the gold fades to warm interior light

**Emotional Beat:** Admiration. Hero worship. The promise of a future together.

---

### Scene 3: Dining Room (Flashback — The Last Celebration)

**Setting:** Small apartment dining room. Warm overhead light. Table set for three — Ma, Jeffrey, Marcus. Birthday cake with "11" candles, freshly blown out. A single balloon floats nearby. Roxbury triple-decker apartment — small but warm.

**Context:** This is the last perfect memory. Jeffrey is alive, happy, full of promise. The player feels — without being told — that this moment is precious. The absence isn't shown; it's felt in the weight of the stillness.

**Sequence:**
1. Dissolve from golden court light to warm interior
2. First-person, seated at table
3. Ma sits across, tired but happy, watching her sons
4. Jeffrey sits adjacent, wearing the wristband (the same one Marcus now wears in present day)
5. Cake sits in center, the small celebration of a family that doesn't need much
6. Balloon drifts gently in frame, within reach
7. **INTERACTION: Gentle push to pass balloon to Jeffrey**
8. Balloon floats to Jeffrey, he bats it back playfully, then catches it
9. He looks directly at camera — the playfulness fades, replaced by something serious, knowing
10. Hold on his face. The warmth of the room.
11. Screen slowly whites out
12. His voice (whispered, reverbed, almost a memory of a voice): *"Keep your mind on the game."*
13. White holds — then resolves to bright stadium lights

**Emotional Beat:** The unbearable tenderness of ordinary moments. This is what Marcus carries. This is why he plays.

---

### Scene 4: Championship Court (Present — Resolution)

**Setting:** Championship game. Bright gymnasium lights. Roar of crowd (muffled, then swelling). Polished wood floor. Boston city championship — the game Jeffrey never got to play.

**Sequence:**
1. White fade resolves to blinding court lights
2. First-person, standing at center court. D (best friend) nearby.
3. Camera tilts down — the wristband on Marcus's wrist, vivid against the polished floor
4. Jeffrey's theme swells, transformed — no longer nostalgic, now powerful
5. D passes to Marcus. Their eyes meet — he understands.
6. Marcus catches. A memory flashes — Jeffrey's hands guiding his.
7. Heartbeat steadies. Breath calms. Ready.
8. Final frame holds on Marcus facing his moment
9. Slow fade to black
10. Title card: **"One More Shot"**
11. End

**Emotional Beat:** Resolution. Jeffrey is still here — in the wristband, in the game. Marcus carries him forward. D is there to support him.

---

## Interaction Design

### Motion Control System

**Input Method:** Webcam-based hand tracking via MediaPipe Hands

**Detection Zones:** All interactions occur in the center panel area (Florence-style framing), simplifying detection bounds

| Gesture | Detection Logic | Tolerance |
|---------|-----------------|-----------|
| Catch (hands up) | Both palms detected, y-position rises above threshold, palms facing camera | Generous — any upward hand movement |
| Pass (push forward) | Palm(s) detected moving toward camera (z-depth change or scale increase) | Medium — deliberate push motion |
| Balloon release | Single hand, gentle forward motion, slower velocity than pass | Gentle — soft movement rewarded |

**Fallback:** If no hands detected for 5+ seconds during interaction prompt, subtle visual hint pulses (soft glow on interaction target). After 15 seconds, auto-advance with graceful transition.

**Philosophy:** Gestures should feel like natural human movements, not "game inputs." No success/fail states — the interaction is about participation, not performance.

---

## Panel System Architecture

### Core Concept

The game displays one **window** (panel) at a time, centered on screen. The camera pans horizontally or vertically to reveal new windows. A **scene** is composed of one or more windows arranged in a strip or grid.

```
Scene 2: Outdoor Court
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│ Panel 1 │ Panel 2 │ Panel 3 │ Panel 4 │ Panel 5 │
│ Wide    │ Jeffrey │ "One    │ Wait    │ Shot    │
│ court   │ tired   │ more"   │ for     │ goes    │
│ view    │         │         │ pass    │ in      │
└─────────┴─────────┴─────────┴─────────┴─────────┘
          ←── camera pans ──→
```

### Panel Layouts Per Scene

**Scene 1: Locker Room (4 panels, horizontal)**
| Panel | Content | Interaction | Duration |
|-------|---------|-------------|----------|
| 1 | Wide locker room, seated POV | None | 3s auto |
| 2 | Teammates walking past (silhouettes) | None | 4s auto |
| 3 | Final teammate at door, tosses ball | None | 2s auto |
| 4 | Ball approaching, hands must rise | **CATCH** | Wait for gesture |

**Scene 2: Outdoor Court (5 panels, horizontal)**
| Panel | Content | Interaction | Duration |
|-------|---------|-------------|----------|
| 1 | Golden court wide shot, fence, flyers | None | 3s auto |
| 2 | Jeffrey under hoop, catching breath | None | 3s auto |
| 3 | Jeffrey straightens, grins, gestures "one more" | None | 3s auto |
| 4 | Jeffrey sets position, waiting | **PASS** | Wait for gesture |
| 5 | Ball arcs, Jeffrey catches, shoots, swish, points at camera | None | 5s auto |

**Scene 3: Dining Room (4 panels, horizontal)**
| Panel | Content | Interaction | Duration |
|-------|---------|-------------|----------|
| 1 | Table wide shot — three seats, cake, warmth | None | 3s auto |
| 2 | Ma's face, soft smile | None | 2s auto |
| 3 | Jeffrey with wristband, balloon floating nearby | **BALLOON** | Wait for gesture |
| 4 | Jeffrey catches balloon, looks at camera, serious, white fade + whispered line | None | 5s + white fade |

**Scene 4: Championship (3 panels, horizontal)**
| Panel | Content | Interaction | Duration |
|-------|---------|-------------|----------|
| 1 | White resolves to bright court lights | None | 2s auto |
| 2 | Looking down at wristband on wrist | None | 3s auto |
| 3 | Camera rises to face court, hold, fade to title | None | 5s + fade to black |

**Total: 16 panels, 3 interactions**

### Panel Transitions

**Transition Types:**
| Type | Use Case | Easing |
|------|----------|--------|
| `pan_left` | Moving forward in time within scene | ease_in_out, 0.8s |
| `pan_right` | Rare — not used in scoped version | ease_in_out, 0.8s |
| `dissolve` | Scene-to-scene transitions (Scene 1→2, 2→3) | linear, 1.2s |
| `white_fade` | Scene 3 ending (Jeffrey's line) → Scene 4 | ease_in, 1.5s |
| `black_fade` | Final fade to title card | ease_out, 1.0s |

### Window Viewport Specifications

**Visible window:** 70% of screen width, centered
**Letterboxing:** Soft vignette on edges, not hard black bars
**Aspect ratio:** 16:9 internal panels, displayed within wider canvas
**Panel spacing:** Panels are adjacent with no gap (seamless pan)

```
┌──────────────────────────────────────────┐
│ ░░░░░ ┌─────────────────────┐ ░░░░░░░░░ │
│ ░░░░░ │                     │ ░░░░░░░░░ │
│ ░░░░░ │   Active Panel      │ ░░░░░░░░░ │
│ ░░░░░ │                     │ ░░░░░░░░░ │
│ ░░░░░ └─────────────────────┘ ░░░░░░░░░ │
└──────────────────────────────────────────┘
  vignette    visible area      vignette
```

### Godot Implementation

**Scene Structure:**
```
SceneRoot (Node2D)
├── PanelStrip (Node2D) ← camera targets this
│   ├── Panel1 (Node2D) @ x=0
│   │   ├── Background (Sprite2D)
│   │   ├── Midground (Sprite2D)
│   │   └── Foreground (Sprite2D)
│   ├── Panel2 (Node2D) @ x=1920
│   │   └── ...
│   └── Panel3 (Node2D) @ x=3840
│       └── ...
├── Camera2D (centered, follows PanelStrip)
├── VignetteOverlay (CanvasLayer)
└── InteractionLayer (CanvasLayer)
    └── HandPrompt (when waiting for gesture)
```

**Panel Controller Script:**
```gdscript
class_name PanelController
extends Node2D

signal panel_completed(panel_index: int)
signal scene_completed

@export var panels: Array[PanelData] = []
@export var transition_type: TransitionType = TransitionType.PAN_LEFT
@export var panel_width: float = 1920.0

var current_panel: int = 0
var camera: Camera2D

func _ready() -> void:
    camera = $Camera2D
    _start_panel(0)

func _start_panel(index: int) -> void:
    current_panel = index
    var panel_data = panels[index]
    
    if panel_data.interaction != Interaction.NONE:
        _wait_for_interaction(panel_data.interaction)
    else:
        await get_tree().create_timer(panel_data.duration).timeout
        _advance()

func _advance() -> void:
    emit_signal("panel_completed", current_panel)
    
    if current_panel >= panels.size() - 1:
        emit_signal("scene_completed")
        return
    
    var next_x = (current_panel + 1) * panel_width
    await _pan_to(next_x)
    _start_panel(current_panel + 1)

func _pan_to(target_x: float) -> void:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(camera, "position:x", target_x, 0.8)
    await tween.finished

func _wait_for_interaction(interaction: Interaction) -> void:
    # Show subtle prompt after delay
    await get_tree().create_timer(2.0).timeout
    _show_interaction_hint(interaction)
    
    # Wait for gesture detector signal
    match interaction:
        Interaction.CATCH:
            await GestureDetector.catch_detected
        Interaction.PASS:
            await GestureDetector.pass_detected
        Interaction.BALLOON:
            await GestureDetector.balloon_released
    
    _hide_interaction_hint()
    _advance()
```

**Panel Data Resource:**
```gdscript
class_name PanelData
extends Resource

@export var duration: float = 3.0
@export var interaction: Interaction = Interaction.NONE
@export var transition_out: TransitionType = TransitionType.PAN_LEFT
@export var background: Texture2D
@export var layers: Array[Texture2D] = []

enum Interaction { NONE, CATCH, PASS, BALLOON }
enum TransitionType { PAN_LEFT, PAN_RIGHT, PAN_DOWN, PAN_UP, DISSOLVE, WHITE_FADE, BLACK_FADE }
```

---

## Visual Design

### Art Direction

**Style:** Illustrated 2D with soft edges, limited palette, emotional lighting. Influenced by Inoue's watercolors, Florence's warmth, and indie visual novels.

**Technique:**
- Hand-drawn or digitally painted key frames
- Layered parallax for depth (foreground hands, midground characters, background environment)
- Animation via Godot tweens, not frame-by-frame
- Motion blur and light bloom for transitions

**Color Scripts:**

| Scene | Palette | Mood |
|-------|---------|------|
| Locker Room | Cool blues, grey, single warm accent (ball) | Tension, anticipation |
| Outdoor Court | Golden amber, warm shadows, sun flare | Nostalgia, warmth, admiration |
| Dining Room | Warm yellows, soft whites, candlelight feel | Intimacy, tenderness, the last perfect moment |
| Championship Court | Bright whites, stark contrast, single warm accent (wristband) | Clarity, resolve, carrying forward |

### Character Rendering

- **Jeffrey Cole:** Full figure in Scenes 2 and 3. Expressive face, confident in Scene 2, tender in Scene 3. The emotional anchor.
- **D (Best Friend):** Visible in Scene 4. Supportive presence, passes to Marcus before the final moment.
- **Ma:** Partial figure in Scene 3, soft focus. Presence without focus.
- **Teammates:** Silhouettes in Scene 1. They matter, but this isn't their story.
- **Player's hands (Marcus):** Detailed, visible in lower frame during interactions. The wristband is always visible.

---

## Audio Design

### Music

**Approach:** Leitmotif-driven. A single melodic phrase represents Jeffrey, woven through all scenes.

| Scene | Music Character |
|-------|-----------------|
| Locker Room | Sparse piano, low drone, anticipation |
| Outdoor Court | Warm acoustic guitar or strings, gentle rhythm, nostalgic |
| Dining Room | Tender, full statement of Jeffrey's theme, bittersweet |
| Championship | Theme returns transformed — fuller, resolved, triumphant |

**Production:** Suno for initial generation, then edited/layered for cohesion. Or licensed from Artlist/Epidemic if budget allows.

### Sound Design

| Element | Sound |
|---------|-------|
| Ball catch | Soft leather impact, satisfying thud |
| Ball pass | Whoosh, slight spin sound |
| Ball swish | Net sound, satisfying — Jeffrey's perfect shot |
| Balloon | Soft tap, gentle air movement |
| Flashback transitions | Reverb swell, frequency shift (present → memory) |
| White fade (Scene 3→4) | High tone, ethereal swell |
| Heartbeat | Subtle, grounds player in body |
| Breathing | Player's breath in final scene — calm, ready |

**Dialogue:** Jeffrey's final line "Keep your mind on the game" — whispered, heavily reverbed, almost subliminal. Testing needed to confirm it adds rather than detracts.

---

## Technical Architecture

### Godot Project Structure

```
one-more-shot/
├── project.godot
├── assets/
│   ├── sprites/
│   │   ├── scene1_locker/
│   │   │   ├── panel1_wide/
│   │   │   ├── panel2_teammates/
│   │   │   ├── panel3_doorway/
│   │   │   └── panel4_catch/
│   │   ├── scene2_court/
│   │   │   ├── panel1_wide/
│   │   │   ├── panel2_d_tired/
│   │   │   ├── panel3_one_more/
│   │   │   ├── panel4_waiting/
│   │   │   └── panel5_shot/
│   │   ├── scene3_dining/
│   │   │   ├── panel1_table/
│   │   │   ├── panel2_ma/
│   │   │   ├── panel3_balloon/
│   │   │   └── panel4_final/
│   │   └── scene4_championship/
│   │       ├── panel1_lights/
│   │       ├── panel2_wristband/
│   │       └── panel3_court/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── ui/
│       ├── vignette.png
│       └── interaction_hints/
├── resources/
│   ├── panel_data/
│   │   ├── scene1_panels.tres
│   │   ├── scene2_panels.tres
│   │   ├── scene3_panels.tres
│   │   └── scene4_panels.tres
│   └── transitions/
├── scenes/
│   ├── main.tscn
│   ├── components/
│   │   ├── panel_strip.tscn
│   │   ├── vignette_overlay.tscn
│   │   └── interaction_prompt.tscn
│   ├── scene1_locker.tscn
│   ├── scene2_court.tscn
│   ├── scene3_dining.tscn
│   └── scene4_championship.tscn
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd
│   │   ├── panel_controller.gd
│   │   ├── panel_data.gd
│   │   └── transition_manager.gd
│   ├── input/
│   │   ├── hand_tracking.gd
│   │   └── gesture_detector.gd
│   ├── audio/
│   │   └── audio_manager.gd
│   └── scenes/
│       └── scene_base.gd
├── shaders/
│   ├── vignette.gdshader
│   ├── dissolve.gdshader
│   ├── desaturate.gdshader
│   └── bloom.gdshader
└── addons/
    └── mediapipe_bridge/
```

### Hand Tracking Integration

**Option A: WebSocket Bridge (Recommended for Jam)**
- Python script runs MediaPipe, sends hand landmarks via WebSocket
- Godot connects as client, receives JSON payloads
- Decoupled, easy to debug, cross-platform

**Option B: GDExtension**
- Native integration, lower latency
- More setup time, less flexible
- Consider for post-jam polish

**Gesture Detection (GDScript pseudocode):**

```gdscript
class_name GestureDetector

signal catch_detected
signal pass_detected
signal balloon_released

var hand_history: Array = []
const HISTORY_LENGTH = 10

func process_hand_data(landmarks: Dictionary) -> void:
    hand_history.append(landmarks)
    if hand_history.size() > HISTORY_LENGTH:
        hand_history.pop_front()
    
    match current_expected_gesture:
        "catch":
            if _detect_hands_raised(landmarks):
                emit_signal("catch_detected")
        "pass":
            if _detect_forward_push():
                emit_signal("pass_detected")
        "balloon":
            if _detect_gentle_push():
                emit_signal("balloon_released")

func _detect_hands_raised(landmarks: Dictionary) -> bool:
    # Check if palm y-position crossed threshold
    # Check if palms facing camera (normal vector)
    pass

func _detect_forward_push() -> bool:
    # Analyze hand_history for z-depth change
    # Or palm scale increase over frames
    pass
```

### Scene Transition System

```gdscript
class_name TransitionManager

enum TransitionType { DISSOLVE, PAN_LEFT, PAN_RIGHT, WHITE_FADE, BLACK_FADE }

func transition_to(scene_path: String, type: TransitionType, duration: float = 1.0) -> void:
    match type:
        TransitionType.DISSOLVE:
            await _dissolve_out(duration / 2)
            get_tree().change_scene_to_file(scene_path)
            await _dissolve_in(duration / 2)
        TransitionType.WHITE_FADE:
            await _fade_to_white(duration / 2)
            get_tree().change_scene_to_file(scene_path)
            await _fade_from_white(duration / 2)
```

---

## Asset Production Pipeline

### Panel Count Summary

| Scene | Panels | Interactions | Total Art Assets |
|-------|--------|--------------|------------------|
| Scene 1: Locker | 4 | 1 (catch) | 4 backgrounds + hand layers |
| Scene 2: Court | 5 | 1 (pass) | 5 backgrounds + Jeffrey (3 poses) + hand layers |
| Scene 3: Dining | 4 | 1 (balloon) | 4 backgrounds + Ma + Jeffrey + balloon + hand layers |
| Scene 4: Championship | 3 | 0 | 3 backgrounds + wristband detail |
| **Total** | **16 panels** | **3 interactions** | ~18-22 distinct illustrations |

### Phase 1: Reference & Sketches (Day 1)

1. Gather visual references (Florence screenshots, color mood boards, Boston neighborhood courts)
2. Thumbnail all 16 panels — quick composition sketches
3. Define character key poses (Jeffrey: 4 poses total)
4. Lock color palette per scene
5. Identify which panels share backgrounds (Scene 2 panels 2-4 can share court BG)

### Phase 2: AI-Assisted Backgrounds (Day 1-2)

Generate base backgrounds in Midjourney (niji mode), one per unique environment:

**Locker Room (1 base, 4 panel crops/variations):**
```
anime locker room interior, high school basketball team, dim fluorescent lighting, 
wooden benches, metal lockers, steam, moody atmosphere, wide shot, 
first person perspective, Boston urban school --niji 6 --ar 16:9
```

**Outdoor Court (1 base, multiple angles):**
```
golden hour basketball court, cracked asphalt, chain link fence, 
Boston Dorchester neighborhood park, nostalgic summer evening, warm sunlight, 
lens flare, anime style, painted background, urban --niji 6 --ar 16:9
```

**Dining Room (1 base):**
```
small Boston apartment dining room, warm overhead lighting, 
birthday cake on wooden table, three chairs, intimate family scene, 
triple-decker apartment interior, evening, cozy, anime style --niji 6 --ar 16:9
```

**Championship Court (1 base):**
```
high school gymnasium interior, bright lights, 
polished wooden floor, crowd in bleachers blur, dramatic lighting, 
Boston city championship banner, anime style, first person view --niji 6 --ar 16:9
```

Then paint over / composite in Clip Studio or Krita, export as layered PNGs.

### Phase 3: Character Art (Day 2)

**Jeffrey Cole — 4 poses:**
1. Under hoop, hands on knees, catching breath (Scene 2, Panel 2)
2. Standing, wiping sweat, confident grin (Scene 2, Panel 3)
3. Set position, ready for pass (Scene 2, Panel 4)
4. At table, playful then serious (Scene 3, Panel 3-4)

**D (Best Friend) — 1 pose:**
- On court, passing to Marcus (Scene 4)

**Ma — 1 pose:**
- Seated at table, soft tired smile (Scene 3, Panel 2)

**Player's hands (Marcus) — layered sprites per interaction:**
- Rest position (low frame)
- Rising / motion blur
- Catch position (ball in hands)
- Push forward sequence (3 frames)
- Gentle release (balloon)

**Wristband:**
- Detail texture, Jeffrey's wristband, appears on hands and in close-ups (especially Scene 4)

### Phase 4: Panel Assembly (Day 2-3)

For each panel:
1. Place background layer
2. Add midground elements (characters, objects)
3. Add foreground layer (hands, vignette)
4. Set up parallax offsets for subtle depth movement
5. Configure in PanelData resource

### Phase 5: Audio (Day 3)

1. Generate music themes in Suno
   - Jeffrey's leitmotif (warm, hopeful)
   - Variation for dining room (tender, bittersweet)
   - Resolution for championship (full, triumphant)
2. Source/create SFX (ball sounds, ambient, heartbeat)
3. Record whispered voice line (or generate via ElevenLabs) — "Keep your mind on the game"
4. Set up audio buses: Music, SFX, Voice

### Phase 6: Integration & Polish (Day 3-4)

1. Wire all panels into PanelController per scene
2. Connect scenes via TransitionManager
3. Tune gesture detection thresholds with real webcam
4. Playtest full 16-panel flow
5. Adjust timing, easing curves
6. Add shaders (vignette, bloom)
7. Bug fixes and edge cases

---

## Minimum Viable Experience (Scope Cut Plan)

If time runs short, preserve this core:

| Priority | Element | Cut Strategy |
|----------|---------|--------------|
| P0 | Scene 2 (Court) + Scene 3 (Dining) | The emotional arc — Jeffrey alive and remembered |
| P0 | Pass gesture + Balloon gesture | Core interactions that carry meaning |
| P0 | Music | Even placeholder piano communicates intent |
| P0 | Jeffrey's final line | "Keep your mind on the game" — the heart of it |
| P1 | Scene 1 (Locker) | Can become simple title card + fade to court |
| P1 | Catch gesture | Replace with timed fade if needed |
| P2 | Scene 4 (Championship) | Can become ending card with wristband image + title |
| P3 | Full panel counts | Reduce panels per scene (e.g., 3 instead of 5 for court) |

**Absolute minimum:** Two scenes, two gestures. The outdoor court pass — Jeffrey makes the shot, points at you. The dining room balloon — he catches it, looks at you, and says keep your mind on the game. That's the whole story in 8 panels.

---

## Success Criteria

### Functional
- [ ] All 16 panels display correctly and pan smoothly
- [ ] Player can complete all three interactions using hand gestures
- [ ] Fallback system advances game if no hands detected
- [ ] All transitions play smoothly at 60fps
- [ ] Audio syncs with visual beats and panel transitions
- [ ] Full playthrough: 2-3 minutes

### Emotional
- [ ] Playtesters understand Marcus and Jeffrey's relationship without exposition
- [ ] The dining room scene lands — players feel the weight of Jeffrey's words
- [ ] The final scene feels earned
- [ ] At least one playtester reports feeling moved

### Technical
- [ ] Builds and runs on Windows
- [ ] Webcam initializes without manual configuration
- [ ] No crashes during standard playthrough
- [ ] Panel transitions maintain 60fps

---

## Open Questions

1. **Voice line delivery**
   - "Keep your mind on the game" — whispered, reverbed, almost subliminal
   - **Testing needed:** Does the voice add power or break the wordless spell?
   - Backup: text on screen with Jeffrey's theme swelling, or purely visual/musical

2. **How much do we imply the loss?**
   - Current approach: purely through weight of the memory and the final line
   - The wristband in present day implies inheritance
   - Alternative: add a brief visual cue (empty chair, photo) in Scene 1 or 4
   - Recommendation: keep it subtle — the audience will feel it

3. **Jeffrey's age in dining scene**
   - Currently shows "14" on birthday cake — this is Marcus's birthday
   - Jeffrey is 13-14 in this memory, shortly before he passed
   - Recommendation: make it Marcus's 11th birthday — Jeffrey is there celebrating his little brother, one of the last happy memories

4. **Locker room teammate**
   - Currently anonymous silhouette who tosses the ball
   - Could be a specific teammate with more presence
   - Recommendation: keep anonymous — this is about Marcus and D

## Decisions Made

| Question | Decision |
|----------|----------|
| Jeffrey's shot | Goes in — he was a star, perfect form |
| Jeffrey's death | Implied through tone and weight, not shown explicitly |
| Jeffrey's role | Basketball superstar, Marcus's idol, legacy to inherit |
| Voice line | Include with testing, whispered reverb treatment |
| Platform | Desktop-first, web as stretch goal |
| Scope | 4 scenes, 16 panels — locker, court, dining, championship |
| Setting | Boston (Dorchester, Roxbury) |
| Names | Marcus Cole (player), Jeffrey Cole (brother), D (best friend), Ma (mother) |

---

## References & Inspiration

- *Florence* (2018) — Interaction design, panel structure, wordless storytelling
- *What Remains of Edith Finch* (2017) — First-person vignettes, gesture variety
- *Gris* (2018) — Color as emotional language, minimal UI
- *Unpacking* (2021) — Environmental storytelling through small actions
- Boston basketball culture — the neighborhood courts, the pride, the legacy

---

*One more shot. That's all he asked for. Now you carry him forward.*

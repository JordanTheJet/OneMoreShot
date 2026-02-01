# One More Shot — Video Generation Prompts

## How to Use This Document

**For each panel:**
1. **Video Prompt** — Generate this as a 3-5 second clip in your video model (Kling, Runway, Pika, etc.)
2. **UI Overlay** — Composite these elements on top in Godot (rendered separately, not in video)

**Technical Specs:**
- Resolution: 1920x1080 (16:9)
- Duration: 3-5 seconds per clip
- Style: Anime/illustrated, painterly, warm lighting
- Camera: Mostly static or slow drift — avoid fast movement

---

## Scene 1: Locker Room

### Panel 1.1 — Wide Locker Room

**Video Prompt:**
```
First-person POV sitting on wooden bench in dim high school locker room, 
looking slightly downward at polished concrete floor. Metal lockers line 
the walls, fluorescent lights flicker overhead creating cold blue-green 
cast. Wisps of steam drift slowly from left to right. Dust particles 
float in light shafts. Subtle camera breathing motion, very slight sway. 
Moody, anticipatory atmosphere. Anime style, painted backgrounds, 
cinematic. No people visible in frame. Static shot with ambient motion only.
```

**Duration:** 3 seconds  
**Camera:** Static with subtle breathing sway  
**Loop:** Yes (seamless ambient)

**UI Overlay:**
- Vignette border (soft, dark edges)
- *No hands in this panel*

---

### Panel 1.2 — Teammates Walking Past

**Video Prompt:**
```
First-person POV sitting on bench in locker room, looking up slightly. 
Three to four basketball player silhouettes walk past from left to right, 
backlit by doorway light at end of corridor. Players are dark shapes, 
no facial detail, athletic builds in warm-up gear. Movement is casual, 
unhurried. Fluorescent light overhead. Steam in background. Last figure 
pauses briefly at edge of frame before exiting. Anime style, painted, 
atmospheric. Camera static.
```

**Duration:** 4 seconds  
**Camera:** Static  
**Loop:** No

**UI Overlay:**
- Vignette border
- *No hands in this panel*

---

### Panel 1.3 — Teammate at Doorway Tosses Ball

**Video Prompt:**
```
First-person POV in locker room looking toward bright doorway at end of 
corridor. Single basketball player silhouette stands in doorway, backlit 
by warm gymnasium light. Figure turns toward camera, pauses, then tosses 
basketball underhand toward camera. Ball leaves hands and begins arc 
toward viewer. Figure holds position watching. Dramatic lighting contrast 
between dark locker room and bright doorway. Anime style, cinematic 
composition. Camera static.
```

**Duration:** 3 seconds  
**Camera:** Static  
**Loop:** No  
**Note:** Ball should exit bottom of frame at end

**UI Overlay:**
- Vignette border
- *No hands yet — they appear in next panel*

---

### Panel 1.4 — Ball Approaching + CATCH

**Video Prompt:**
```
First-person POV, basketball approaching camera from distance, growing 
larger as it floats toward viewer in gentle arc. Background is blurred 
locker room with bright doorway. Ball rotates slowly, leather texture 
visible. Shallow depth of field, ball sharp, background soft. Ball 
reaches center frame and stops/hovers at catch position. Anime style, 
soft lighting, intimate moment. Camera static.
```

**Duration:** 3 seconds (holds at end waiting for interaction)  
**Camera:** Static  
**Loop:** Hold on final frame

**UI Overlay (CRITICAL):**
- **Player's hands** — Separate animated sprite layer, rises from bottom of frame
- **Wristband visible** on left wrist
- **Interaction hint** — Subtle glow pulse after 2 seconds if no gesture detected
- Vignette border

---

## Scene 2: Outdoor Court

### Panel 2.1 — Wide Court, Golden Hour

**Video Prompt:**
```
Wide establishing shot of urban basketball court at golden hour, 
Dorchester Boston neighborhood. Cracked asphalt court with faded paint 
lines, chain-link fence surrounding, distant triple-decker houses visible 
beyond. Late summer afternoon, warm orange sunlight, long shadows. 
Lens flare from setting sun. Old tournament flyers flutter slightly on 
fence. Heat shimmer rising from asphalt. Leaves drift occasionally. 
No people in frame. Nostalgic, warm, peaceful. Anime style, Makoto 
Shinkai lighting, painted backgrounds. Camera very slow push in or static.
```

**Duration:** 3 seconds  
**Camera:** Static or very slow push (2% zoom over duration)  
**Loop:** Yes (ambient elements)

**UI Overlay:**
- Vignette border (warmer tone than locker room)
- *No hands in this panel*

---

### Panel 2.2 — D Catching Breath

**Video Prompt:**
```
Medium shot of young Black man (17 years old) in basketball clothes 
standing under basketball hoop on outdoor court, hands on knees, catching 
breath. Golden hour lighting from behind creates rim light on shoulders 
and head. Wearing sleeveless jersey, shorts, the wristband visible on 
left wrist. Sweat glistening on skin. Chest heaving with breath, 
shoulders rising and falling. Expression is tired but content. Chain-link 
fence and houses soft in background. Anime style, warm colors, painterly. 
Camera static, medium close-up.
```

**Duration:** 3 seconds  
**Camera:** Static  
**Loop:** Yes (breathing cycle)

**UI Overlay:**
- Vignette border (warm)
- *No hands — this is observing D*

---

### Panel 2.3 — D Grins, Gestures "One More"

**Video Prompt:**
```
Medium shot of young Black man (17 years old) on outdoor basketball court 
at golden hour. He straightens up from bent position, wipes sweat from 
forehead with back of hand, then breaks into confident easy grin. Makes 
casual hand gesture — holds up one finger, "one more" — while looking 
directly at camera with warm challenging expression. Wristband visible. 
Golden backlight creates glow around him. Charismatic, big brother energy. 
Anime style, expressive face animation, warm tones. Camera static.
```

**Duration:** 3 seconds  
**Camera:** Static  
**Loop:** No (ends on gesture hold)

**UI Overlay:**
- Vignette border (warm)
- *No hands — observing D*

---

### Panel 2.4 — D Sets Position + PASS

**Video Prompt:**
```
Medium-wide shot of young Black man (17 years old) on outdoor basketball 
court moving into ready position to receive pass. He shuffles to his 
spot near three-point line, knees bent, hands up and ready, eyes locked 
on camera with focused intensity. Waiting. Golden hour light, long 
shadows on asphalt. Slight sway in ready stance, athletic anticipation. 
Anime style, dynamic pose, warm lighting. Camera static.
```

**Duration:** Holds waiting for interaction  
**Camera:** Static  
**Loop:** Yes (subtle ready-stance sway)

**UI Overlay (CRITICAL):**
- **Player's hands** — Holding basketball, positioned at chest level
- **Wristband visible** on left wrist
- **Ball** — Separate sprite that animates OUT of frame on gesture
- **Interaction hint** — Subtle arrow or glow after 2 seconds
- Vignette border

---

### Panel 2.5 — The Shot (D catches, shoots, swish, points)

**Video Prompt:**
```
Sequence shot on outdoor basketball court, golden hour. Young Black man 
(17) catches basketball pass from camera direction, immediately flows 
into shooting motion — footwork, elevation, perfect form, releases ball 
at peak of jump. Cut to or track ball swishing through net, nothing but 
net. Cut back to him landing, turning toward camera with triumphant smile, 
points directly at viewer with confident "your turn" energy. Wristband 
visible on pointing hand. Golden light behind him, almost haloed. 
Anime style, fluid animation, emotional peak moment. Dynamic camera 
allowed for this shot.
```

**Duration:** 5 seconds  
**Camera:** Can be dynamic — follow the action  
**Loop:** No (ends on point and hold)

**UI Overlay:**
- Vignette border
- *No player hands — this is watching D*
- Final frame holds for transition timing

---

## Scene 3: Dining Room

### Panel 3.1 — Table Wide Shot

**Video Prompt:**
```
First-person POV seated at small dining table in Boston apartment, 
evening. Warm overhead light casts golden glow on wooden table. 
Birthday cake with "14" candles (just blown out, wisps of smoke rising) 
sits center table. Three place settings visible. Window shows evening 
blue outside. Modest apartment, warm and lived-in. Single balloon 
floats gently at edge of frame, bobbing slightly. Candle smoke wisps 
drift upward. Cozy, intimate, tender atmosphere. Anime style, warm 
palette, Ghibli-esque domestic comfort. Camera static with subtle 
breathing motion.
```

**Duration:** 3 seconds  
**Camera:** Static with subtle sway  
**Loop:** Yes (smoke, balloon bob)

**UI Overlay:**
- Vignette border (warmest of all scenes)
- *No hands in this panel*

---

### Panel 3.2 — Ma's Face

**Video Prompt:**
```
Medium close-up of Black woman (early 40s) seated at dinner table, 
warm overhead lighting. Tired but genuinely happy expression, soft 
smile watching something off-camera (her sons). Modest clothing, 
end of a long workday but present for this moment. Eyes warm with 
love, slight head tilt. Background soft, out of focus warm tones. 
Subtle animation — blinks, slight smile shift, breathing. 
Anime style, gentle character animation, warm intimate lighting. 
Camera static.
```

**Duration:** 2 seconds  
**Camera:** Static  
**Loop:** Yes (subtle breathing/blink cycle)

**UI Overlay:**
- Vignette border (warm)
- *No hands — observing Ma*

---

### Panel 3.3 — D with Balloon + BALLOON PASS

**Video Prompt:**
```
Medium shot of young Black man (17) seated at dinner table, warm 
evening lighting. Wearing casual clothes, the wristband visible on 
wrist resting on table. Relaxed, happy, watching camera (his little 
brother) with easy affection. Single balloon floats nearby at edge 
of frame, drifting gently. Waiting. Background shows modest apartment 
dining room, birthday cake remnants. Tender, ordinary, precious moment. 
Anime style, warm palette, intimate framing. Camera static.
```

**Duration:** Holds waiting for interaction  
**Camera:** Static  
**Loop:** Yes (balloon gentle bob, D subtle idle)

**UI Overlay (CRITICAL):**
- **Player's hands** — At table level or slightly raised
- **Balloon** — Separate sprite that player "pushes" toward D
- **Interaction hint** — Soft glow on balloon after 2 seconds
- Vignette border (warm)

---

### Panel 3.4 — D Catches Balloon, Expression Shift, White Fade

**Video Prompt:**
```
Medium shot of young Black man (17) at dinner table. Balloon floats 
into frame from camera direction, he catches it playfully, bats it 
once with a grin, then catches and holds it. His expression gradually 
shifts — smile fades to something deeper, more serious, looking directly 
at camera with knowing intensity. Eyes say everything. Hold on his 
face as image slowly overexposes to white, bloom increasing until 
pure white frame. Wristband visible in final moments. Tender, 
bittersweet, profound. Anime style, emotional character animation, 
gradual white fade transition. Camera static.
```

**Duration:** 5 seconds (including white fade)  
**Camera:** Static, image fades to white  
**Loop:** No

**UI Overlay:**
- Vignette fades out with white
- *No player hands in this panel*
- **Audio trigger point** for whispered "Keep your mind on the game"

---

## Scene 4: Championship

### Panel 4.1 — White Resolves to Court Lights

**Video Prompt:**
```
Pure white frame gradually resolves as exposure adjusts, revealing 
bright gymnasium lights from below — looking up at ceiling of high 
school basketball court. Multiple bright light fixtures in geometric 
pattern, slight lens flare and bloom. Industrial ceiling, championship 
banners barely visible at edges. Sound of crowd is implied by 
atmosphere. Bright, overwhelming, transitional. Anime style, 
dramatic lighting. Camera static, exposure shift only.
```

**Duration:** 2 seconds  
**Camera:** Static, exposure transition  
**Loop:** No

**UI Overlay:**
- *No vignette — full bright frame*
- *No hands*

---

### Panel 4.2 — Wristband Close-up

**Video Prompt:**
```
Close-up shot looking down at wrist/forearm, first-person POV. 
The wristband (D's wristband) on left wrist, fabric texture visible, 
slightly worn with love. Background is out-of-focus polished wooden 
basketball court floor, bright gymnasium lighting. Subtle pulse or 
glow on wristband (can be added in post). Breathing motion — wrist 
rises and falls slightly. Intimate, weighted moment. Anime style, 
shallow depth of field, emotional focus on small object. Camera static.
```

**Duration:** 3 seconds  
**Camera:** Static with subtle breathing motion  
**Loop:** Yes (breathing)

**UI Overlay:**
- Soft vignette returns
- **Wristband highlight/pulse** — Subtle glow can be added as overlay
- *Player's own wrist is the video — no separate hand layer*

---

### Panel 4.3 — Camera Rises to Face Court

**Video Prompt:**
```
First-person POV, camera tilts up from looking at wrist/floor to 
facing forward across championship basketball court. Gymnasium comes 
into view — polished wood floor with court lines, far basket, crowd 
in bleachers as impressionistic blur of color and movement. Teammates 
visible in periphery as soft shapes. Bright overhead lights. Crowd 
noise swells (implied). Camera movement is steady, resolute, arriving 
at moment of truth. Hold on final frame facing court ahead. 
Anime style, dramatic reveal, triumphant composition. Slow tilt up 
then static hold.
```

**Duration:** 5 seconds (3s tilt, 2s hold, then fade)  
**Camera:** Slow tilt up, then static hold  
**Loop:** No — ends with fade to black

**UI Overlay:**
- Vignette deepens during hold
- **Title card** — "One More Shot" fades in over black
- *No hands*

---

## UI Elements Master List

These are rendered separately in Godot and composited over video:

### Player Hands (Marcus)
| Asset | Used In | Notes |
|-------|---------|-------|
| Hands at rest (low) | 1.4 start | Below frame, ready to rise |
| Hands rising | 1.4 interaction | Tween animation upward |
| Hands catch position | 1.4 end | Holding ball |
| Hands holding ball (chest) | 2.4 | Ready to pass |
| Hands push forward | 2.4 interaction | 3-frame push animation |
| Hands at table | 3.3 | Relaxed position |
| Hands gentle push | 3.3 interaction | Soft balloon push |

**Common element:** Wristband visible on left wrist in ALL hand assets

### Interaction Elements
| Asset | Used In | Notes |
|-------|---------|-------|
| Basketball | 1.4, 2.4 | Separate sprite, can be animated |
| Balloon | 3.3 | Separate sprite with gentle bob, floats on push |
| Catch hint glow | 1.4 | Subtle pulse around ball after delay |
| Pass hint arrow | 2.4 | Forward arrow after delay |
| Balloon hint glow | 3.3 | Soft glow on balloon after delay |

### Persistent UI
| Asset | Used In | Notes |
|-------|---------|-------|
| Vignette (cool) | Scene 1 | Blue-grey edges |
| Vignette (warm) | Scene 2, 3 | Golden-brown edges |
| Vignette (bright) | Scene 4 | Minimal, opens up |
| Title card | 4.3 end | "One More Shot" text |

---

## Generation Tips

### Style Consistency
Add to all prompts:
```
Consistent anime art style, painted backgrounds, soft edges, 
limited color palette, emotional lighting, Studio Ghibli meets 
Makoto Shinkai aesthetic, 24fps animation feel
```

### For Character Shots (D, Ma)
Add:
```
Consistent character design, expressive but subtle animation, 
same face across all shots, Black American features, natural 
hair texture, warm skin tones in golden lighting
```

### For First-Person Shots
Add:
```
First-person perspective, no player body visible except hands 
when specified, immersive POV, slight natural camera sway to 
feel embodied
```

### Negative Prompts (if supported)
```
Avoid: 3D render, photorealistic, western cartoon, chibi, 
exaggerated expressions, action lines, speed lines, text, 
watermark, signature, UI elements, harsh shadows
```

---

## File Naming Convention

```
scene[#]_panel[#]_[description]_v[version].mp4

Examples:
scene1_panel4_ball_catch_v1.mp4
scene2_panel5_d_shot_v2.mp4
scene3_panel4_expression_shift_v1.mp4
```

UI overlays:
```
ui_hands_[state].png
ui_ball.png
ui_balloon.png
ui_vignette_[warm/cool].png
ui_hint_[type].png
```

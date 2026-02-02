# Video Generation

Video-to-video stylization tests for converting reference footage into Takehiko Inoue manga style.

## Models Tested

### luma/modify-video ✅ WORKS

**Best option for stylization.** Successfully transforms video with prompt-based style transfer.

```bash
cd image_generation
source .venv/bin/activate
python luma_modify_test.py
```

**Modes (9 total):**
- `adhere_1/2/3` - Subtle changes, close to source
- `flex_1/2/3` - Stylistic changes, still recognizable (recommended)
- `reimagine_1/2/3` - Dramatic transformation

**Constraints:**
- Max 100MB video size
- Max 30 seconds duration

**Output:** `output/scene1_2_luma_flex2.mp4`

---

### kwaivgi/kling-v2.6-motion-control ❌ FAILED

Motion control model that transfers motion from reference video to styled image.

**Issues:**
1. "No complete upper body detected in the video" - Model requires clear upper body visibility
2. "The character in the reference image or the first frame is invalid" - Can't detect characters in manga-style AI images
3. Requires both image AND video input
4. Video must be 3-30 seconds

**Conclusion:** Designed for real photos/videos with detectable human bodies, not for stylizing with illustrated content.

---

### lucataco/animate-diff-vid2vid ❌ FAILED

AnimateDiff-based video-to-video stylization.

**Issues:**
- Returns 404 error - model may be deprecated or unavailable
- Was supposed to accept video + prompt for stylization

**Constraints (documented):**
- `strength`: 0.0-1.0 (higher = more stylization)
- `guidance_scale`: default 7.5
- `num_inference_steps`: default 25

---

## Reference Videos

| File | Duration | Scene | Notes |
|------|----------|-------|-------|
| 1.2.MOV | 8.7s | Teammates walking | ✅ Works with Luma |
| 2.2_zoom.MOV | 2.0s | Jeffrey rest zoom | Too short (<3s) |
| 2.3.MOV | 3.0s | Jeffrey grin | Borderline duration |
| 2.4.MOV | 10.3s | Jeffrey ready | Failed body detection |
| 2.5.MOV | 2.6s | Jeffrey shot | Too short (<3s) |
| 3.1.MOV | 10.1s | Dining table | Untested |
| 3.3.MOV | 7.1s | Jeffrey balloon | Failed character detection |

## Style Prompts

All scripts use Takehiko Inoue style prompts:

```
Takehiko Inoue art style, late Slam Dunk and Vagabond aesthetic,
realistic manga illustration, ink wash painting influence, emotional realism,
dynamic brushwork, high detail, dramatic lighting, painterly textures
```

Character-specific additions include "red Somerville high school basketball jersey" for consistency.

## Output

Generated videos saved to `output/` folder:
- `scene1_2_luma_flex2.mp4` - Stylized 1.2 footage
- `comparison_1_2.mp4` - Side-by-side original vs stylized

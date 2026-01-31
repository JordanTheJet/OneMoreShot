shader_type canvas_item;

// Soft edge darkening vignette effect

uniform float intensity : hint_range(0.0, 1.0) = 0.4;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform float roundness : hint_range(0.0, 1.0) = 0.8;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = UV;

	// Center the UV coordinates
	vec2 centered_uv = uv - vec2(0.5);

	// Adjust for aspect ratio if needed
	// centered_uv.x *= (1.0 / roundness);

	// Calculate distance from center
	float dist = length(centered_uv * vec2(1.0, roundness));

	// Create smooth vignette
	float vignette = smoothstep(0.5 - softness * 0.5, 0.5 + softness * 0.5, dist);

	// Apply intensity
	vignette *= intensity;

	// Output: blend vignette color with alpha
	COLOR = vec4(vignette_color.rgb, vignette * vignette_color.a);
}

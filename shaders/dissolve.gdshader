shader_type canvas_item;

// Dissolve transition effect using noise

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D noise_texture : hint_default_white;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Sample noise for dissolve pattern
	float noise = texture(noise_texture, UV * noise_scale).r;

	// Calculate dissolve threshold
	float threshold = progress;

	// Create edge glow
	float edge = smoothstep(threshold - edge_width, threshold, noise) -
				 smoothstep(threshold, threshold + edge_width, noise);

	// Calculate alpha
	float alpha_mask = step(noise, threshold);

	// Mix edge color
	vec3 final_color = mix(tex_color.rgb, edge_color.rgb, edge * (1.0 - alpha_mask));

	COLOR = vec4(final_color, tex_color.a * (1.0 - alpha_mask));
}

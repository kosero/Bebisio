shader_type canvas_item;

uniform float freq_times_PI : hint_range(0.0, 10.0) = 2.0;
uniform float strength : hint_range(0.0, 1.0) = 0.1;
uniform float center : hint_range(0.0, 1.0) = 0.5;
uniform float wave_speed : hint_range(0.0, 10.0) = 1.0;
uniform float amp_osc_freq : hint_range(0.0, 5.0) = 0.5;

uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_thickness : hint_range(0.0, 0.1) = 0.02;

uniform vec4 bg_color : source_color = vec4(1.0, 1.0, 1.0, 0.2);

float get_circle_dist(vec2 uv) {
    vec2 centered_uv = (uv - 0.5) * 2.0;
    return length(centered_uv);
}

float get_wave_y(vec2 uv) {
    float amp_mod = sin(TIME * amp_osc_freq);
    float dynamic_amp = strength * amp_mod;
    return dynamic_amp * sin(freq_times_PI * PI * uv.x + TIME * wave_speed) + (1.0 - center);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    float circle_radius = 0.8;
    float dist_from_center = get_circle_dist(UV);
    float wave_y = get_wave_y(UV);

    bool inside_circle = dist_from_center < circle_radius;
    bool inside_wave = UV.y > wave_y;
    bool is_circle_border = inside_circle && (circle_radius - dist_from_center) < (border_thickness * 2.0);

    if (is_circle_border)
        COLOR = border_color;

    else if (inside_circle) {
        if (inside_wave) {
            COLOR = mix(bg_color, tex_color, tex_color.a);
        } else {
            COLOR = bg_color;
        }
    }
    else {
        COLOR = vec4(0.0);
    }
}

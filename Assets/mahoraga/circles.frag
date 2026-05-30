#version 440
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D circleMask;

void main() {
    vec2 uv = texCoord;

    vec4 base = texture(source, uv);

    // Read circle mask — white areas are where circles live
    float mask = texture(circleMask, uv).r;

    // Two rings offset in time so they overlap nicely — like two ripples
    float ring1 = mod(time,        1.0);
    float ring2 = mod(time + 0.5,  1.0);  // second ring starts halfway through

    // Distance from each ring front — creates an expanding thin band
    float dist1 = abs(mask - ring1);
    float dist2 = abs(mask - ring2);

    // Thin glowing ring — sharper falloff = thinner line
    float glow1 = smoothstep(0.06, 0.0, dist1) * (1.0 - ring1);  // fades as it expands
    float glow2 = smoothstep(0.06, 0.0, dist2) * (1.0 - ring2);

    float glow = max(glow1, glow2);

    // Add the glow on top of the base image — soft blue-white tint
    vec3 ringColor = vec3(0.7, 0.85, 1.0);
    base.rgb = mix(base.rgb, base.rgb + ringColor * glow * 0.6, mask);

    fragColor = base * qt_Opacity;
}

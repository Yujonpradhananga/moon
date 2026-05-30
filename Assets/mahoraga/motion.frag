#version 440

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float strength;   // ripple displacement amount
    float speed;      // how fast rings expand
    float frequency;  // ring density (rings per unit)
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D depthMask;

void main() {
    vec2 uv = texCoord;

    // Depth mask — only bright areas (the moon lines) ripple
    float mask = texture(depthMask, uv).r;
    float sharpMask = smoothstep(0.15, 0.6, mask);

    // Multiple ripple centers for a richer look
    // Each center produces expanding rings, offset in time so they're staggered
    vec2 center1 = vec2(0.5, 0.5);
    vec2 center2 = vec2(0.3, 0.35);
    vec2 center3 = vec2(0.68, 0.62);

    vec2 disp = vec2(0.0);

    // Helper: add one ripple source
    // Rings expand outward: phase = freq*dist - speed*time
    // sin() of that gives the ripple wave
    // Envelope = 1/dist fades it naturally with distance

    // Center 1 — main large ripple
    {
        vec2 delta = uv - center1;
        float dist  = length(delta) + 0.0001;
        float wave  = sin(dist * frequency * 40.0 - time * speed);
        float amp   = wave * strength * (1.0 / (1.0 + dist * 4.0));
        disp += normalize(delta) * amp;
    }

    // Center 2 — secondary ripple, slightly out of phase
    {
        vec2 delta = uv - center2;
        float dist  = length(delta) + 0.0001;
        float wave  = sin(dist * frequency * 38.0 - time * speed * 0.85 + 2.1);
        float amp   = wave * strength * 0.6 * (1.0 / (1.0 + dist * 5.0));
        disp += normalize(delta) * amp;
    }

    // Center 3 — tertiary ripple, slower
    {
        vec2 delta = uv - center3;
        float dist  = length(delta) + 0.0001;
        float wave  = sin(dist * frequency * 42.0 - time * speed * 0.7 + 4.2);
        float amp   = wave * strength * 0.45 * (1.0 / (1.0 + dist * 5.5));
        disp += normalize(delta) * amp;
    }

    // Gate displacement by depth mask — background stays still
    vec2 finalDisp = disp * sharpMask;

    fragColor = texture(source, uv + finalDisp) * qt_Opacity;
}

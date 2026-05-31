#version 440
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    float time;
    float strength;
    float speed;
    float frequency;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D depthMask;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void main() {
    float t = time * 0.01;

    float rawMask = texture(depthMask, texCoord).r;
    float mask = smoothstep(0.15, 0.6, rawMask);

    vec4 originalColor = texture(source, texCoord);
    vec3 sparkle = vec3(0.0);

    for (int i = 0; i < 60; i++) {
        float fi = float(i);

        float seed  = hash(vec2(fi, 0.3));
        float seed2 = hash(vec2(fi, 1.7));
        float seed3 = hash(vec2(fi, 2.5));
        float seed4 = hash(vec2(fi, 3.9));

        // Fixed X lane per star with slight drift
        float xPos = seed;
        float fallSpeed = 1.5 + seed2 * 2.0;
        float yPos = fract(seed3 + t * fallSpeed);

        // Slight horizontal drift as it falls
        xPos += (seed4 - 0.5) * 0.08 * yPos;

        vec2 starPos = vec2(xPos, yPos);
        vec2 delta   = texCoord - starPos;
        delta.x *= 16.0 / 9.0;
        float dist = length(delta);

        // Fade in at top, fade out at bottom
        float fade = smoothstep(0.0, 0.08, yPos) * (1.0 - smoothstep(0.75, 1.0, yPos));

        // Shrink as it falls
        float sizeFactor = 1.0 - yPos * 0.7;

        // Bright glowing core
        float core = 0.00008 / (dist * dist + 0.00001);
        core = clamp(core, 0.0, 1.0) * sizeFactor;

        // Cross flare
        float hFlare = clamp(0.00003 / (abs(delta.y) + 0.0005), 0.0, 1.0) * step(dist, 0.05) * sizeFactor;
        float vFlare = clamp(0.00003 / (abs(delta.x) + 0.0005), 0.0, 1.0) * step(dist, 0.05) * sizeFactor;

        // Twinkle
        float twinkle = 0.6 + 0.4 * sin(t * 20.0 * (1.0 + seed * 3.0) + fi);

        // Color — white to blue-white
        vec3 color = mix(vec3(1.0, 1.0, 1.0), vec3(0.7, 0.85, 1.0), seed);

        sparkle += (core + hFlare + vFlare) * fade * twinkle * color;
    }

    sparkle = clamp(sparkle, 0.0, 1.0);

    vec3 finalRGB = originalColor.rgb + sparkle * mask;
    finalRGB = clamp(finalRGB, 0.0, 1.0);

    fragColor = vec4(finalRGB, originalColor.a) * qt_Opacity;
}

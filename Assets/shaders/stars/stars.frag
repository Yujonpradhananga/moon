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
    float t = time * 0.01; // fast

    float rawMask = texture(depthMask, texCoord).r;
    float mask = smoothstep(0.15, 0.6, rawMask);

    vec4 originalColor = texture(source, texCoord);
    vec3 sparkle = vec3(0.0);

    for (int i = 0; i < 60; i++) {
        float fi = float(i);

        float seed  = hash(vec2(fi, 0.3));
        float seed2 = hash(vec2(fi, 1.7));
        float seed3 = hash(vec2(fi, 2.5));

        // Fixed X lane per star
        float xPos = seed;

        // Fall fast from top to bottom, wrap back to top
        float fallSpeed = 1.5 + seed2 * 2.0;
        float yPos = fract(seed3 + t * fallSpeed);

        vec2 starPos = vec2(xPos, yPos);
        vec2 delta   = texCoord - starPos;
        delta.x *= 16.0 / 9.0;
        float dist = length(delta);

        // Simple bright point
        float core = 0.00008 / (dist * dist + 0.00001);
        core = clamp(core, 0.0, 1.0);

        sparkle += core;
    }

    sparkle = clamp(sparkle, 0.0, 1.0);

    vec3 finalRGB = originalColor.rgb + sparkle * mask;
    finalRGB = clamp(finalRGB, 0.0, 1.0);

    fragColor = vec4(finalRGB, originalColor.a) * qt_Opacity;
}

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
    float t = time * 0.0008;

    float rawMask = texture(depthMask, texCoord).r;
    float mask = smoothstep(0.15, 0.6, rawMask);

    vec4 originalColor = texture(source, texCoord);
    vec3 sparkle = vec3(0.0);

    for (int i = 0; i < 60; i++) {
        float fi = float(i);

        // Each sparkle has fixed random properties
        float seed  = hash(vec2(fi, fi * 0.3));
        float seed2 = hash(vec2(fi * 0.7, fi * 1.3));
        float seed3 = hash(vec2(fi * 1.1, fi * 0.9));

        // Start position — random Y, enters from right
        float yPos = seed;
        float xPos = fract(seed2 - t * (0.5 + seed3 * 1.5));

        vec2 starPos = vec2(xPos, yPos);
        vec2 delta = texCoord - starPos;
        // Aspect ratio correction
        delta.x *= 16.0 / 9.0;
        float dist = length(delta);

        // Bright glowing core
        float core = 0.00008 / (dist * dist + 0.00001);
        core = clamp(core, 0.0, 1.0);

        // Cross flare
        float hFlare = clamp(0.00003 / (abs(delta.y) + 0.0005), 0.0, 1.0) * step(dist, 0.05);
        float vFlare = clamp(0.00003 / (abs(delta.x) + 0.0005), 0.0, 1.0) * step(dist, 0.05);

        // Twinkle
        float twinkle = 0.5 + 0.5 * sin(t * 30.0 * (1.0 + seed * 5.0) + fi);

        // Color varies per star
        vec3 color = mix(vec3(1.0, 1.0, 1.0), vec3(0.7, 0.85, 1.0), seed);

        sparkle += (core + hFlare + vFlare) * twinkle * color;
    }

    sparkle = clamp(sparkle, 0.0, 1.0);

    vec3 finalRGB = originalColor.rgb + sparkle * mask;
    finalRGB = clamp(finalRGB, 0.0, 1.0);

    fragColor = vec4(finalRGB, originalColor.a) * qt_Opacity;
}

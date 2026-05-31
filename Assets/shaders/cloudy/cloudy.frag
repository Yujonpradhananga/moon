#version 440
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float strength;
    float speed;
    float frequency;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D depthMask;

// Hash function for pseudo-random values
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123);
}

// Smooth noise returning a vec2 offset
vec2 smoothNoise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    vec2 u = f * f * (3.0 - 2.0 * f); // smoothstep curve

    vec2 a = hash2(i + vec2(0.0, 0.0));
    vec2 b = hash2(i + vec2(1.0, 0.0));
    vec2 c = hash2(i + vec2(0.0, 1.0));
    vec2 d = hash2(i + vec2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
    float t = time * speed;

    // Sample the depth mask at the original coordinate
    float rawMask = texture(depthMask, texCoord).r;
    float mask = smoothstep(0.15, 0.6, rawMask);

    // Build a layered distortion offset from two noise octaves
    vec2 noiseUV1 = texCoord * frequency * 6.0 + vec2(t * 0.13, t * 0.07);
    vec2 noiseUV2 = texCoord * frequency * 12.0 + vec2(-t * 0.09, t * 0.11);

    vec2 offset1 = (smoothNoise(noiseUV1) * 2.0 - 1.0);
    vec2 offset2 = (smoothNoise(noiseUV2) * 2.0 - 1.0) * 0.5;

    vec2 totalOffset = (offset1 + offset2) * strength;

    // Distorted UV — only shift within masked areas
    vec2 distortedUV = texCoord + totalOffset * mask;

    // Sample source with distorted coords
    vec4 distortedColor = texture(source, distortedUV);
    vec4 originalColor  = texture(source, texCoord);

    // Blend: masked areas get distortion, background stays clean
    vec4 color = mix(originalColor, distortedColor, mask);

    fragColor = color * qt_Opacity;
}

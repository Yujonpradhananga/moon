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
layout(binding = 3) uniform sampler2D normalMap;

void main() {
    float t = time * speed;

    // Sample the depth mask
    float rawMask = texture(depthMask, texCoord).r;
    float mask = smoothstep(0.15, 0.6, rawMask);

    // Sample normal map for distortion
    vec2 normalUV = texCoord * frequency + vec2(t * 0.13, t * 0.07);
    vec2 normalOffset = (texture(normalMap, normalUV).rg * 2.0 - 1.0) * strength;

    // Distorted UV — only within masked areas
    vec2 distortedUV = texCoord + normalOffset * mask;

    // Sample source
    vec4 distortedColor = texture(source, distortedUV);
    vec4 originalColor  = texture(source, texCoord);

    // Invert the distorted color on masked areas
    vec4 invertedColor = vec4(1.0 - distortedColor.rgb, distortedColor.a);

    // Blend: masked areas get distortion + inversion, background stays clean
    vec4 color = mix(originalColor, invertedColor, mask);
    fragColor = color * qt_Opacity;
}

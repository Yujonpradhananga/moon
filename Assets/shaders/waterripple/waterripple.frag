#version 440
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float rippleStrength;
    float rippleX;
    float rippleY;
    float rippleAge;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D normalMapSource;
layout(binding = 4) uniform sampler2D depthMask;

void main() {
    vec2 uv = texCoord;

    float mask = texture(depthMask, uv).r;

    vec2 scroll1 = uv + vec2( time * 0.0003,  time * 0.0002);
    vec2 scroll2 = uv + vec2(-time * 0.0002,  time * 0.0003);
    vec2 n1 = texture(normalMapSource, scroll1).rg * 2.0 - 1.0;
    vec2 n2 = texture(normalMapSource, scroll2).rg * 2.0 - 1.0;
    vec2 normalDisplace = (n1 + n2) * 0.5 * rippleStrength * 0.01 * mask;


    vec2 finalUV = uv + normalDisplace;
    fragColor = texture(source, finalUV) * qt_Opacity;
}

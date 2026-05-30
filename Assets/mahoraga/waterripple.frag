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

void main() {
    vec2 uv = texCoord;

    // Two layers of normal map scrolling in different directions for organic feel
    vec2 scroll1 = uv + vec2( time * 0.0003,  time * 0.0002);
    vec2 scroll2 = uv + vec2(-time * 0.0002,  time * 0.0003);

    vec2 n1 = texture(normalMapSource, scroll1).rg * 2.0 - 1.0;
    vec2 n2 = texture(normalMapSource, scroll2).rg * 2.0 - 1.0;
    vec2 normalDisplace = (n1 + n2) * 0.5 * rippleStrength * 0.01;

    // Mouse ripple: expanding ring that fades over time
    vec2  delta     = uv - vec2(rippleX, rippleY);
    float dist      = length(delta);
    float waveFront = dist - rippleAge * 0.4;
    float fade      = exp(-rippleAge * 2.0);
    float ringFade  = exp(-dist * 15.0);
    float wave      = sin(waveFront * 35.0) * fade * ringFade * 0.8;
    vec2  mouseDisplace = normalize(delta + vec2(0.0001)) * wave * 0.04;

    vec2 finalUV = uv + normalDisplace + mouseDisplace;
    fragColor = texture(source, finalUV) * qt_Opacity;
}

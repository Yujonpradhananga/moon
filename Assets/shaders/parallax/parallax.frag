#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float offsetX;
    float offsetY;
    float parallaxStrength;
    float aspectRatio;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;

    float shift = parallaxStrength * 0.05;

    // zoom in by the max possible shift amount so edges are always covered
    float zoom = 1.0 - shift * 2.0;
    uv = (uv - 0.5) * zoom + 0.5;

    // now apply offset — it will always stay within the zoomed bounds
    uv.x += offsetX * shift;
    uv.y += offsetY * shift;

    fragColor = texture(source, uv) * qt_Opacity;
}

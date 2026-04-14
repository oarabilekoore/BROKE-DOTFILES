#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pix = texture(tex, v_texcoord);
    vec3 color = pix.rgb;
    
    // Boost Saturation
    float lum = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(lum), color, 1.5);
    
    // Boost Contrast
    color = mix(vec3(0.5), color, 1.3);
    
    fragColor = vec4(color, 1.0);
}

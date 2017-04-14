precision mediump float;
uniform sample2D texture;
varying vec2 TextureCoordsOut


void main(void)
{
    vec4 mask =texture2D(texture,TextureCoordsOut);
    gl_FragColor =vec4(mask.rgb,1.0);
}

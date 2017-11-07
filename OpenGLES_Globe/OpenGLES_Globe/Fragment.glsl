precision mediump float;
uniform sampler2D Texture;
varying vec2 TextureCoordsFrag;


void main(void)
{
    vec4 mask = texture2D(Texture, TextureCoordsFrag);
    gl_FragColor = vec4(mask.rgb,1.0);

}






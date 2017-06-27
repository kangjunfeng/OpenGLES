precision mediump float;
uniform sampler2D Texture;
varying vec2 TextureCoordsFrag;
varying vec4 vPosition;


void main(void)
{
    float uR = 0.5;
    vec4 color =vec4(1.0,1.0,1.0,1.0);
    float n = 8.0;
    float span = 2.0*uR/n;
    
    int i = int((vPosition.x + uR)/span);
    int j = int((vPosition.y + uR)/span);
    int k = int((vPosition.z + uR)/span);
    int colorType = int(mod(float(i+j+k),2.0));
    if (colorType==1) {
        color = vec4(0.2,1.0,0.129,1.0);
    }else {
        color = vec4(1.0,1.0,1.0,1.0);
    }
    
    vec4 mask = texture2D(Texture, TextureCoordsFrag);
    gl_FragColor = vec4(mask.rgb,1.0);

}






attribute vec4 Position;
attribute vec2 TextureCoords;
varying   vec2 TextureCoordsFrag;

void main(void)
{
    gl_Position = Position;
    TextureCoordsFrag = TextureCoords;
}

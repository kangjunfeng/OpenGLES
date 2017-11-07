attribute vec4 Position;
attribute vec2 TextureCoords;
varying   vec2 TextureCoordsFrag;

uniform mat4 Matrix;

void main(void)
{
    gl_Position = Matrix * vec4(Position.x,Position.y,Position.z,1.0);
    TextureCoordsFrag = TextureCoords;
}

attribute vec4 Position;
attribute vec2 TextureCoords;
varying   vec2 TextureCoordsFrag;

varying vec4 vPosition;
uniform mat4 Matrix;
uniform mat4 eyeMatrix;
uniform mat4 projMatrix;
uniform mat4 modeMatrix;


void main(void)
{
    gl_Position = Matrix * vec4(Position.x,-Position.y,Position.z,1.0);
//     gl_Position =  vec4(Position.x,-Position.y,Position.z,1.0);
    TextureCoordsFrag = TextureCoords;
    vPosition = Position * Matrix;
}

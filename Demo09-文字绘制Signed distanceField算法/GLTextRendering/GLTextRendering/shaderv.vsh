attribute vec4 position;
attribute vec2 textCoordinate;

uniform vec4 vertexColor;
uniform mat4 rotateMatrix;

varying lowp vec4 color;
varying lowp vec2 varyTextCoord;

void main()
{
    varyTextCoord = textCoordinate;
    vec4 vPos = position;
    color = vertexColor;
    vPos = vPos * rotateMatrix;
    gl_Position = vPos;
}

attribute vec4 position;
attribute vec2 inputTextureCoordinate;

varying lowp vec2 textureCoordinate;

void main(void) {
    textureCoordinate = inputTextureCoordinate;
    gl_Position = position;
}


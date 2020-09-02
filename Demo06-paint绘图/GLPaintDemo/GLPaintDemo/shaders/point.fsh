uniform sampler2D texture;
varying lowp vec4 color;

void main()
{
	gl_FragColor = color * texture2D(texture, gl_PointCoord);
}

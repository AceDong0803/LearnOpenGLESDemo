
#extension GL_OES_standard_derivatives : enable

varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;
varying lowp vec4 color;

void main()
{
   mediump float edgeDistance = 0.5;
   mediump float sampleDistance = texture2D(colorMap, varyTextCoord).r;
   mediump float edgeWidth = 0.75 * length(vec2(dFdx(sampleDistance), dFdy(sampleDistance)));
   mediump float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
   gl_FragColor = vec4(color.r, color.g, color.b, insideness);;
}

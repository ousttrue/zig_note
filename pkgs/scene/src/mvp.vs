#version 330
in vec3 aPos;
uniform mediump mat4 uMVP;

void main() {
  gl_Position = uMVP * vec4(aPos, 1);
}

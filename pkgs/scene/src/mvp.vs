#version 330
in vec3 aPos;
in vec3 aNom;
in vec3 aCol;
out vec3 vCol;
uniform mediump mat4 uMVP;

void main() {
  gl_Position = uMVP * vec4(aPos, 1);
  vCol = aCol;
}

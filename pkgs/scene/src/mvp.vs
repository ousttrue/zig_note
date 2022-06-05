#version 330
in vec3 aPos;
in vec3 aNormal;
in vec3 aColor;
out vec3 vColor;
uniform mediump mat4 uMVP;

void main() {
  gl_Position = uMVP * vec4(aPos, 1);

  // lambert
  vec3 L = normalize(vec3(-1, -2, -3));
  vec3 N = normalize(aNormal);
  float v = max(dot(N, L), 0.2);
  vColor = aColor * v;
}

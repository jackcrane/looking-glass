precision mediump float;

varying vec2 v_texCoord;
uniform sampler2D u_image;
uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform sampler2D u_characters;

void main() {
  vec2 aspectRatio = vec2(u_resolution.x / u_resolution.y, 1.0);

  // Normalize mouse position and adjust for aspect ratio
  vec2 normalizedMouse = u_mouse / u_resolution;
  vec2 normalizedTexCoord = v_texCoord;

  // Scale only the x-coordinate of the distance calculation
  vec2 scaledDistance = (normalizedTexCoord - normalizedMouse) * aspectRatio;

  float blockSize = 8.0; // Block size in pixels
  vec2 normalizedBlockSize = vec2(blockSize) / u_resolution;

  vec2 pixelCoord = v_texCoord * u_resolution;
  vec2 blockRelativeCoord = mod(pixelCoord, blockSize);
  vec2 blockCoord = floor(pixelCoord / blockSize) * blockSize / u_resolution;
  vec4 blockColor = texture2D(u_image, blockCoord);

  bool onEdge = blockRelativeCoord.x < 1.0 || blockRelativeCoord.y < 1.0;

  // Use the true pixel-based radius for the circle
  float radius = 64.0 / min(u_resolution.x, u_resolution.y);

  // Calculate the four corners of the block
  vec2 blockTopLeft = blockCoord;
  vec2 blockTopRight = blockCoord + vec2(normalizedBlockSize.x, 0.0);
  vec2 blockBottomLeft = blockCoord + vec2(0.0, normalizedBlockSize.y);
  vec2 blockBottomRight = blockCoord + normalizedBlockSize;

  // Check if all corners are inside the circle
  bool canCompleteBlock =
      length((blockTopLeft - normalizedMouse) * aspectRatio) < radius &&
      length((blockTopRight - normalizedMouse) * aspectRatio) < radius &&
      length((blockBottomLeft - normalizedMouse) * aspectRatio) < radius &&
      length((blockBottomRight - normalizedMouse) * aspectRatio) < radius;

  float blockLuminance = dot(blockColor.rgb, vec3(0.299, 0.587, 0.114));
  // Band luminance to 8 values
  float quantizedBlockLuminance = floor(blockLuminance * 8.0) / 8.0;

  if (length(scaledDistance) < radius) {

    if(canCompleteBlock) {
      // if(onEdge) {
      //   gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
      // } else {
      //   gl_FragColor = blockColor;
      // }

      // gl_FragColor = blockColor;
      gl_FragColor = vec4(quantizedBlockLuminance, quantizedBlockLuminance, quantizedBlockLuminance, 1.0);
    }
  } else {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
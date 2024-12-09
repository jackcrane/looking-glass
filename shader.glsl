precision mediump float;

varying vec2 v_texCoord;
uniform sampler2D u_image;
uniform sampler2D u_characters;
uniform vec2 u_mouse;
uniform vec2 u_resolution;

void main() {
    // Compute aspect ratio
    vec2 aspectRatio = vec2(u_resolution.x / u_resolution.y, 1.0);

    // Normalize texture coordinates and mouse position
    vec2 normalizedTexCoord = v_texCoord;
    vec2 normalizedMouse = u_mouse / u_resolution;

    // Calculate block size and coordinate in pixel space
    float blockSize = 8.0;
    vec2 pixelCoord = v_texCoord * u_resolution;
    vec2 blockCoord = floor(pixelCoord / blockSize) * blockSize / u_resolution;

    // Sample the image to get the block's average color
    vec4 blockColor = texture2D(u_image, blockCoord);

    // Compute luminance of the block
    float blockLuminance = dot(blockColor.rgb, vec3(0.299, 0.587, 0.114));
    float quantizedBlockLuminance = floor(blockLuminance * 10.0); // Map to 10 levels (0-9)

    // Determine character position in the u_characters texture
    float characterIndex = quantizedBlockLuminance; // Index for the character
    float characterWidth = 1.0 / 10.0; // Each character is 1/10th of the texture width
    float characterHeight = 1.0; // Full height of the texture
    vec2 characterCoord = vec2(characterIndex * characterWidth, 0.0);

    // Align block-relative coordinates to character's 8x8 grid
    vec2 blockRelativeCoord = mod(pixelCoord, blockSize) / blockSize;
    vec2 characterTexCoord = characterCoord + blockRelativeCoord * vec2(characterWidth, characterHeight);

    // Sample the u_characters texture at the computed coordinate
    vec4 characterColor = texture2D(u_characters, characterTexCoord);

    vec4 invertedCharacterColor = vec4(1.0 - characterColor.r, 1.0 - characterColor.g, 1.0 - characterColor.b, 1.0);

    // Compute the distance from the mouse
    float radius = 64.0 / min(u_resolution.x, u_resolution.y);
    float distanceToMouse = length((normalizedTexCoord - normalizedMouse) * aspectRatio);

    // If the pixel is within the radius, draw the character multiplied by the block color; otherwise, make it transparent
    if (distanceToMouse < radius) {
        gl_FragColor = invertedCharacterColor * blockColor; // Multiply character color by block color
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent
    }
}
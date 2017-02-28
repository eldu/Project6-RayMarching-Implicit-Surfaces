
#define MAX_GEOMETRY_COUNT 100

/* This is how I'm packing the data
struct geometry_t {
    vec3 position;
    float type;
};
*/

// Reference: https://threejs.org/docs/api/renderers/webgl/WebGLProgram.html
// Already loaded into the fragment shader!
// uniform mat4 viewMatrix
// uniform vec3 cameraPosition;

// Referemce: 461 Slides, TY Adam.

uniform vec4 u_buffer[MAX_GEOMETRY_COUNT];
uniform int u_count;
uniform vec2 u_size;
uniform mat4 u_inverseViewProjectionMatrix;
uniform float u_far;


varying vec2 f_uv;

// Ray
vec4 f_rayPos;
vec4 f_rayDir;

void main() {
	// Calculate NDC	
	float ndc_x = 2.0 * f_uv.x / u_size.x - 1.0;
	float ndc_y = 1.0 - 2.0 * f_uv.y / u_size.y;
	vec4 f_ndc = vec4(ndc_x, ndc_y, 1.0, 1.0);

	// Calculate Ray
	vec4 P = u_inverseViewProjectionMatrix * f_ndc * u_far;
	f_rayPos = vec4(cameraPosition, 1.0); // TODO: Confirm that cameraPosition = eye...
	f_rayDir = normalize(P - f_rayPos);

    float t;
    for (int i = 0; i < MAX_GEOMETRY_COUNT; ++i) {
        if (i >= u_count) {
            break;
        }
    }

    gl_FragColor = vec4(f_uv, 0, 1);
}
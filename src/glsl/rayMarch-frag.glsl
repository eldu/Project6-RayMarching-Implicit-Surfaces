
#define MAX_GEOMETRY_COUNT 100
#define FLT_EPSILON 0.0000001
#define MIN_STEP 0.0001

/* This is how I'm packing the data
struct geometry_t {
    vec3 position;
    float type;
};
*/
// geometry_t is a vec4


// Reference: https://threejs.org/docs/api/renderers/webgl/WebGLProgram.html
// Already loaded into the fragment shader!
// uniform mat4 viewMatrix
// uniform vec3 cameraPosition;

// Referemce: 461 Slides, TY Adam.

// Reference: http://graphics.cs.williams.edu/courses/cs371/f14/reading/implicit.pdf

uniform vec4 u_buffer[MAX_GEOMETRY_COUNT];
uniform int u_count;
uniform vec2 u_size;
uniform mat4 u_inverseViewProjectionMatrix;
uniform float u_far;


varying vec2 f_uv;

// Ray
vec4 f_rayPos;
vec4 f_rayDir;


float sdfBox(vec4 geo) {

}

float sdfSphere(vec4 geo) {

}

float sdfCone(vec4 geo) {

}

// Iterates through all of the geometries in the scene
// Returns the sdf value for the closest object
float sdf() {
	float minDist = u_far; // Far clip plane is the farthest
	float d = u_far;

    for (int i = 0; i < MAX_GEOMETRY_COUNT; ++i) {
        vec4 geo = u_buffer[i];

        if (geo.w == 0) {
			// Box
			d = sdfBox(geo);

		} else if (geo.w == 1) {
			// Sphere
			d = sdfSphere(geo);
		} else if (geo.w == 3) {
			// Cone
			d = sdfCone(geo);
		}

		if (d < minDist) {
			minDist = d;
		}

        if (i >= u_count) {
            break;
        }
    }

    return minDist;
}


void main() {
	// GENERATE RAYS
	// Calculate NDC	
	float ndc_x = 2.0 * f_uv.x / u_size.x - 1.0;
	float ndc_y = 1.0 - 2.0 * f_uv.y / u_size.y;
	vec4 f_ndc = vec4(ndc_x, ndc_y, 1.0, 1.0);

	// Calculate Ray
	vec4 P = u_inverseViewProjectionMatrix * f_ndc * u_far;
	f_rayPos = vec4(cameraPosition, 1.0); // TODO: Confirm that cameraPosition = eye...
	f_rayDir = normalize(P - f_rayPos);

	// SPHERE TRACING
	// Check if farther than the far clip plane
	float t = 0.0;
	float dt = sdf(); // SDF through the scene
	while (t < u_far && dt > FLT_EPSILON) {
		t = t + max(dt, MIN_STEP);
		dt = sdf();
	}
	// return t

	// Marched position starts at ray position
	float mPos = f_rayPos + t * f_rayDir;

    // Get the geometry that is closest


    gl_FragColor = vec4(f_uv, 0, 1);
}

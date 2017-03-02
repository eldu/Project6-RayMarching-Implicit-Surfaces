
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

// Reference: 461 Slides, TY Adam.
// Reference: http://graphics.cs.williams.edu/courses/cs371/f14/reading/implicit.pdf
// Reference: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

uniform vec4 u_buffer[MAX_GEOMETRY_COUNT];
uniform int u_count;
uniform vec2 u_size;
uniform mat4 u_inverseViewProjectionMatrix;
uniform float u_far;


varying vec2 f_uv;

// Ray
vec4 f_rayPos;
vec4 f_rayDir;


// All sdf formulas assume that the shape is centered around the origin
float sdfBox(vec3 pos) {
	return length(max(abs(pos) - vec3(0.5), 0.0));
}

// Sphere with 0.5 Radius
float sdfSphere(vec3 pos) {
	return length(pos) - 0.5;
}

// TODO: Cone, with one cap?
float sdfCone(vec3 pos) {
	vec2 c = vec2(1.0);
	float q = length(pos.xy);
	return dot(c, vec2(q, pos.z));
}

float sdfTorus(vec3 pos) {
	vec2 q = vec2(length(pos.xz) - 1.0, pos.y);
	return length(q) - 0.5;
}

// Cylinder with Caps
float sdfCylinder(vec3 pos) {
	vec2 d = abs(vec2(length(pos.xz), pos.y)) - vec2(1.0);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Iterates through all of the geometries in the scene
// Returns the sdf value for the closest object
float sdf(vec3 pos) {
	float minDist = u_far; // Far clip plane is the farthest
	float d = u_far;

    for (int i = 0; i < MAX_GEOMETRY_COUNT; ++i) {
        vec4 geo = u_buffer[i];
        vec3 local = pos - geo.xyz;

        if (geo.w == 0.0) {
			// Box
			d = sdfBox(local);

		} else if (geo.w == 1.0) {
			// Sphere
			d = sdfSphere(local);
		} else if (geo.w == 2.0) {
			// Cone
			d = sdfCone(local);
		}

		minDist = min(d, minDist);

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
	float dt = sdf(f_rayPos.xyz); // SDF through the scene
	for (int i = 0; i < 100; i++) { // 100 iterations
		if (t < u_far && dt > FLT_EPSILON) {
			break;
		}

		t = t + max(dt, MIN_STEP);
		dt = sdf(f_rayPos.xyz);
	}

	// Marched position starts at ray position
	vec4 mPos = f_rayPos + t * f_rayDir;


    // Get the geometry that is closest
    gl_FragColor = vec4(f_uv, 0, 1);
}

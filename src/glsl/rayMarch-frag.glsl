
#define MAX_GEOMETRY_COUNT 100
#define FLT_EPSILON 0.0000001
#define MIN_STEP 0.00000000000001

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
uniform vec3 u_cameraPosition;
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
// Centered around the origin
float sdfSphere(vec3 pos) {
	return length(pos) - 0.5;
}

// TODO: Cone, with one cap?
float sdfCone(vec3 pos) {
	vec3 c = vec3(1.0);
	vec2 q = vec2(length(pos.xz), pos.y);
	vec2 v = vec2(c.z * c.y / c.x, -c.z); // 1, -1
	vec2 w = v - q;
	vec2 vv = vec2(dot(v, v), v.x * v.x);
	vec2 qv = vec2(dot(v, w), v.x * w.x);
	vec2 d = max(qv, 0.0) * qv / vv;

	return sqrt(dot(w, w) - max(d.x, d.y)) * sign(max(w.y, q.y * v.x - q.x * v.y));
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
	float d = 0.0;

    for (int i = 0; i < MAX_GEOMETRY_COUNT; i++) {
        vec4 geo = u_buffer[i];
        vec3 local = pos - geo.xyz;

        if (geo.w == 0.0) {
		// 	// Box
			//d = sdfBox(local);
			d = sdfSphere(local);
		} else if (geo.w == 1.0) {
		// 	// Sphere
			d = sdfBox(local);
			// d = sdfSphere(local);
		} else if (geo.w == 2.0) {
		// 	// Cone
		 	d = sdfCone(local);
		}

		minDist = min(d, minDist);

        if (i >= u_count) {
            break;
        }
    }

    return minDist;
}



// From slides: https://cis700-procedural-graphics.github.io/files/implicit_surfaces_2_21_17.pdf
vec3 estimateNormal(vec3 p) {
	return normalize(vec3(
		sdf(vec3(p.x + FLT_EPSILON, p.y, p.z)) - sdf(vec3(p.x - FLT_EPSILON, p.y, p.z)),
		sdf(vec3(p.x, p.y + FLT_EPSILON, p.z)) - sdf(vec3(p.x, p.y - FLT_EPSILON, p.z)),
		sdf(vec3(p.x, p.y, p.z + FLT_EPSILON)) - sdf(vec3(p.x, p.y, p.z - FLT_EPSILON))
		));
}

vec4 sphereTrace(vec4 pos, vec4 dir) {
	float t = 0.0;
	float dt = sdf(pos.xyz); // SDF through the scene

	for (int i = 0; i < 100; i++) { // 100 iterations
		if (t >= u_far || dt < FLT_EPSILON) {
			break;
		}

		t = t + max(abs(dt), MIN_STEP) * sign(dt);
		dt = sdf(pos.xyz + t * dir.xyz);
	}

	return pos + t * dir;
}

vec4 lambert(vec3 norm, vec3 light) {
	return vec4(vec3(clamp(dot(norm, light), 0.0, 1.0)), 1.0);
}

void main() {
	// GENERATE RAYS
	// Calculate NDC	
	float ndc_x = 2.0 * f_uv.x - 1.0;
	float ndc_y = 2.0 * f_uv.y - 1.0;
	vec4 f_ndc = vec4(ndc_x, ndc_y, 1.0, 1.0);

	// Calculate Ray
	vec4 P = u_inverseViewProjectionMatrix * (f_ndc * u_far);
	f_rayPos = vec4(u_cameraPosition, 1.0);
	f_rayDir = normalize(P - f_rayPos);

	// SPHERE TRACING
	// Check if farther than the far clip plane
	// Marched position starts at f_rayPos
	vec4 mPos = sphereTrace(f_rayPos, f_rayDir);

	// Get Normal
	vec3 norm = estimateNormal(mPos.xyz);

	gl_FragColor = vec4(lambert(norm, vec3(0.57735, 0.57735, 0.57735)));
	//gl_FragColor = vec4(norm.xyz, 1.0);
}
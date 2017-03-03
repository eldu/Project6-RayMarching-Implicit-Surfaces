# HW 6: Ray marching and SDFs

## Goal
In this assignment, you will be implementing SDF operators on various primitives and use a ray marcher to render them. Ray marching is a technique for rendering implicit surfaces where the ray-primitive intersection equation cannot be solved analytically.

### Ray Marcher (25 pts)
The ray marcher generates a ray and marchs through the scene using the distances computed from sphere tracing.
- Generate Rays (15 pts): for each fragment inside the fragment shader, compute a ray direction for the ray marcher
- Sphere Tracing (10 pts): compute the nearest distance from the scene SDFs and update the ray marching's step size.

### SDF (50 pts)
##### Implement primitive SDFs (15pts):
These are simple primitives with well-defined SDFs. We encourage trying other SDFs not listed here, they are interesting! 
  - Sphere (3pts)
  - Box (3pts)
  - Cone (3pts)
  - Torus (3pts)
  - Cylinder (3pts)

##### Useful Operators (15pts)
To create constructive geometry, and interesting shapes (such as holes, bumps, etc.), implement the following operators to combine your primitive SDFs.
  - Intersection (2pts)
  - Subtraction (3pts)
  - Union (2pts)
  - Transformation (8pts)
    - translation and scaling
##### Compute normals based on gradient (15 pts)

Compute the normals to use for shading your surface.
- Read Chapter 13 of [Morgan McGuire's notes](http://graphics.cs.williams.edu/courses/cs371/f14/reading/implicit.pdf) 
##### Material (5pts)
Implement a simple Lambert material. Additional materials can earn extra points.

### Custom Scene (25 pts)
##### Create a mechanical device or a scene of your choice using all operators 
  - intersection, subtraction, union, transformation (20pts)
##### Animate the scene (5pts)
Use time as an input to some of your functions to animate your scene!

## Resources
http://graphics.cs.williams.edu/courses/cs371/f14/reading/implicit.pdf
https://threejs.org/docs/api/renderers/webgl/WebGLProgram.html
http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
461 Slides, TY Adam.
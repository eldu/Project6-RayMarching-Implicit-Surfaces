const THREE = require('three');
const EffectComposer = require('three-effectcomposer')(THREE)

import {PROXY_BUFFER_SIZE} from './proxy_geometry'

export default function RayMarcher(renderer, scene, camera) {
    var composer = new EffectComposer(renderer);
    var shaderPass = new EffectComposer.ShaderPass({
        uniforms: {
            u_buffer: {
                type: '4fv',
                value: undefined
            },
            u_count: {
                type: 'i',
                value: 0
            },
            u_cameraPosition: {
                type: 'v3',
                value: new THREE.Vector3()
            },
            u_inverseViewProjectionMatrix: {
                type: 'm4',
                value: new THREE.Matrix4()
            },
            u_far: {
                type: 'f',
                value: 1000.0 // TODO: Get far clip plane from camera
            }
        },
        vertexShader: require('./glsl/pass-vert.glsl'),
        fragmentShader: require('./glsl/rayMarch-frag.glsl')
    });
    shaderPass.renderToScreen = true;
    composer.addPass(shaderPass);

    return {
        render: function(buffer) {
            camera.updateMatrixWorld();
            camera.updateProjectionMatrix();

            shaderPass.material.uniforms.u_buffer.value = buffer;
            shaderPass.material.uniforms.u_count.value = buffer.length / PROXY_BUFFER_SIZE;

            shaderPass.material.uniforms.u_cameraPosition.value = camera.position;


            var projMat = camera.projectionMatrix;
            var viewMat = camera.matrixWorldInverse;

            var viewProjMat = projMat.clone().multiply(viewMat); // Cloned in case it saves to projMat instead
            shaderPass.material.uniforms.u_inverseViewProjectionMatrix.value = viewProjMat.getInverse(viewProjMat);
       
            composer.render();
        }
    }
}
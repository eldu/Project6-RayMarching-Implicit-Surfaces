require('file-loader?name=[name].[ext]!../index.html');

const THREE = require('three');
const OrbitControls = require('three-orbit-controls')(THREE)

import DAT from 'dat-gui'
import Stats from 'stats-js'
import ProxyGeometry, {ProxyMaterial} from './proxy_geometry'
import RayMarcher from './rayMarching'

var BoxGeometry = new THREE.BoxGeometry(1, 1, 1);
var SphereGeometry = new THREE.SphereGeometry(1, 32, 32);
var ConeGeometry = new THREE.ConeGeometry(1, 1);
var TorusGeometry = new THREE.TorusGeometry(1, 0.2, 16, 100);
var CylinderGeometry = new THREE.CylinderGeometry(0.5, 0.5, 1, 100);
var SphereCubeCutoutGeometry = new THREE.TorusKnotGeometry(); // Stand in geometry for a sphere cube
var UnionGeometry = new THREE.RingGeometry(); // Stand in geometry for three spheres stacked on top of each other
var IntersectionGeometry = new THREE.IcosahedronGeometry(); // Stand in geometry for intersection example


window.addEventListener('load', function() {
    var stats = new Stats();
    stats.setMode(1);
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.left = '0px';
    stats.domElement.style.top = '0px';
    document.body.appendChild(stats.domElement);

    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
    var renderer = new THREE.WebGLRenderer( { antialias: true } );
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x999999, 1.0);
    document.body.appendChild(renderer.domElement);

    var controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.enableZoom = true;
    controls.rotateSpeed = 0.3;
    controls.zoomSpeed = 1.0;
    controls.panSpeed = 2.0;

    window.addEventListener('resize', function() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });

    var gui = new DAT.GUI();

    var options = {
        strategy: 'Ray Marching'
    }

    gui.add(options, 'strategy', ['Ray Marching', 'Proxy Geometry']);

    scene.add(new THREE.AxisHelper(20));
    scene.add(new THREE.DirectionalLight(0xffffff, 1));

    var proxyGeometry = new ProxyGeometry();

    var boxMesh = new THREE.Mesh(BoxGeometry, ProxyMaterial);
    var sphereMesh = new THREE.Mesh(SphereGeometry, ProxyMaterial);
    var coneMesh = new THREE.Mesh(ConeGeometry, ProxyMaterial);
    var torusMesh = new THREE.Mesh(TorusGeometry, ProxyMaterial);
    var cylinderMesh = new THREE.Mesh(CylinderGeometry, ProxyMaterial);
    var spherecubecutoutMesh = new THREE.Mesh(SphereCubeCutoutGeometry, ProxyMaterial);
    var unionMesh = new THREE.Mesh(UnionGeometry, ProxyMaterial);
    var intersectionMesh = new THREE.Mesh(IntersectionGeometry, ProxyMaterial);
    
    boxMesh.position.set(-3, 0, 0);
    coneMesh.position.set(3, 0, 0);
    torusMesh.position.set(6, 0, 0);
    cylinderMesh.position.set(9, 0, 0);
    spherecubecutoutMesh.position.set(0, 0, -6);
    unionMesh.position.set(3, 0, -6);
    intersectionMesh.position.set(6, 0, -6);

    proxyGeometry.add(boxMesh);
    proxyGeometry.add(sphereMesh);
    proxyGeometry.add(coneMesh);
    proxyGeometry.add(torusMesh);
    proxyGeometry.add(cylinderMesh);
    proxyGeometry.add(spherecubecutoutMesh);
    proxyGeometry.add(unionMesh);
    proxyGeometry.add(intersectionMesh);

    scene.add(proxyGeometry.group);

    camera.position.set(5, 5, 15);
    camera.lookAt(new THREE.Vector3(0,0,0));
    controls.target.set(0,0,0);
    
    var rayMarcher = new RayMarcher(renderer, scene, camera);



    (function tick() {
        controls.update();
        stats.begin();
        proxyGeometry.update(Date.now());
        if (options.strategy === 'Proxy Geometry') {
            renderer.render(scene, camera);
        } else if (options.strategy === 'Ray Marching') {
            rayMarcher.render(proxyGeometry.buffer);
        }
        stats.end();
        requestAnimationFrame(tick);
    })();
});
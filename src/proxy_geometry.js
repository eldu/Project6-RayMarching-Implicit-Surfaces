const THREE = require('three');

export var ProxyMaterial = new THREE.MeshLambertMaterial({
    color: 0xff0000
});

export const PROXY_BUFFER_SIZE = 4;

export default class ProxyGeometry {
    constructor(bounds) {
        this.group = new THREE.Group();
        this._buffer = new Float32Array();
    }

    add(mesh) {
        this.group.add(mesh);
        this._buffer = new Float32Array(PROXY_BUFFER_SIZE * this.group.children.length);
        this.computeBuffer();
    }

    remove(mesh) {
        this.group.remove(mesh);
        this._buffer = new Float32Array(PROXY_BUFFER_SIZE * this.group.children.length);
        this.computeBuffer();
    }

    update(t = 1/60) {
        const {children} = this.group;
        for (let i = 0; i < children.length; ++i) {
            const child = children[i];
            children[i].position.set(
                children[i].position.x,
                children[i].position.y + Math.sin(children[i].position.x) * Math.sin(t / 1000.0) / 2.0,
                children[i].position.z);
        }
        this.computeBuffer();
    }

    computeBuffer() {
        const {children} = this.group;
        for (let i = 0; i < children.length; ++i) {
            const child = children[i];
            this._buffer[PROXY_BUFFER_SIZE*i] = child.position.x;
            this._buffer[PROXY_BUFFER_SIZE*i+1] = child.position.y;
            this._buffer[PROXY_BUFFER_SIZE*i+2] = child.position.z;

            if (child.geometry instanceof THREE.BoxGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 1;
            } else if (child.geometry instanceof THREE.SphereGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 0;
            } else if (child.geometry instanceof THREE.ConeGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 2;
            } else if (child.geometry instanceof THREE.TorusGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 3;
            } else if (child.geometry instanceof THREE.CylinderGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 4;
            // Custom Geometries
            // These geometries are just stand ins
            } else if (child.geometry instanceof THREE.TorusKnotGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 5;
            } else if (child.geometry instanceof THREE.RingGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 6;
            } else if (child.geometry instanceof THREE.IcosahedronGeometry) {
                this._buffer[PROXY_BUFFER_SIZE*i+3] = 7;
            }
        }
    }

    get buffer() {
        return this._buffer;
    }
}
Stage3d 		= require("makio/core/Stage3d")
Stage 			= require("makio/core/Stage")
GeometryFactory = require("makio/3d/Cache3d")

class Sprite extends THREE.Mesh

	constructor:(map=null)->
		material = @createMaterial(map)
		geometry = @createGeometry()
		super(geometry,material)
		return

	createMaterial:(map)->
		@uniforms = {
			ratio:{type:'f', value:Stage.width/Stage.height}
			xPercent:{type:'f', value:-.35}
			yPercent:{type:'f', value:-.25}
			widthPercent:{type:'f', value:.25}
			heightPercent:{type:'f', value:.25}
			opacity:{type:'f', value:0.5}
			map:{type:'t', value:map}
		}
		material = new THREE.ShaderMaterial(
			uniforms:@uniforms
			vertexShader:require('sprite.vs')
			fragmentShader:require('sprite.fs')
			transparent:true
		)
		return material

	createGeometry:()->
		indices = new Uint16Array( [ 0, 1, 2,  0, 2, 3 ] );
		vertices = new Float32Array( [ - 1, - 1, 0,   1, - 1, 0,   1, 1, 0,   - 1, 1, 0 ] );
		uvs = new Float32Array( [ 0, 0,   1, 0,   1, 1,   0, 1 ] );
		geometry = new THREE.BufferGeometry();
		geometry.setIndex( new THREE.BufferAttribute( indices, 1 ) );
		geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) );
		geometry.addAttribute( 'uv', new THREE.BufferAttribute( uvs, 2 ) );
		return geometry

module.exports = Sprite

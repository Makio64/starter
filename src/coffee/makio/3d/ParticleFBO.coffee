#
# Points system using FBO for position.
# @author David Ronai / http://makiopolis.com / @makio64
#

FBO = require('./FBO')
Stage = require('makio/core/Stage')
Stage3d = require('makio/core/Stage3d')
Random = require('makio/utils/Random')
M = require('makio/math/M')
gui = require('makio/core/GUI')
CanvasUtils = require('makio/utils/CanvasUtils')
Interactions = require('makio/core/Interactions')

class ParticleFBO extends THREE.Points

	constructor:(@width, @height, renderer)->

		@simulationMaterial = @createSimulationMaterial()
		@renderMaterial = @createRenderMaterial()
		geometry = @createGeometry()
		super(geometry,@renderMaterial)

		@fbo = new FBO( @width, @height, renderer, @simulationMaterial )
		Stage.onUpdate.add(@update)
		return

	switchToSim:(material)=>
		material.uniforms.time = {type:'f', value:@simulationMaterial.uniforms.time}
		material.minFilter = THREE.NearestFilter
		material.magFilter = THREE.NearestFilter
		@simulationMaterial = material
		@fbo.setSimulation material
		return

	createSimulationMaterial:()=>
		material = new THREE.ShaderMaterial(
			uniforms: {
				t_pos: { type: "t", value: @createData(@width,@height)  }
				t_oPos: { type: "t", value: null }
				time: { type: "f", value: 0 }
	    	}
			vertexShader: require( "fbo/simulation.vs" )
			fragmentShader: require( "particles/sim01.fs" )
		)
		material.minFilter = THREE.NearestFilter
		material.magFilter = THREE.NearestFilter
		return material

	createRenderMaterial:()=>
		@renderMaterial = new THREE.ShaderMaterial( {
			uniforms: {
				t_pos: { type: "t", value: null }
				t_oPos: { type: "t", value: null }
				texture: { type: "t", value: null }
				time: { type: "f", value: 0 }
    		},
			blending:THREE.AdditiveBlending
			vertexShader: require( "particles/render.vs" )
			fragmentShader: require( "particles/render.fs" )
			transparent: true
			depthWrite: false
			depthTest: false
		} )
		loader = new THREE.TextureLoader()
		loader.load(
			'img/particle.jpg',
			(texture)=>
				texture.needsUpdate = true
				@renderMaterial.uniforms.texture.value = texture
				return

		)
		return @renderMaterial

	createGeometry:()->
		size = @width * @height
		positions = new Float32Array( size*3 )
		for i in [0...positions.length] by 1
			positions[ i * 3 ] = ( i % @width ) / @width
			positions[ i * 3 + 1 ] = Math.floor( i / @width ) / @height

		geometry = new THREE.BufferGeometry()
		geometry.addAttribute( 'position',  new THREE.BufferAttribute( positions, 3 ) )
		geometry.computeBoundingSphere()
		return geometry

	createData:()=>
		dataPosition = Random.data(@width,@height,400)
		position = new THREE.DataTexture( dataPosition, @width, @height, THREE.RGBFormat, THREE.FloatType, THREE.DEFAULT_MAPPING, THREE.RepeatWrapping, THREE.RepeatWrapping )
		position.minFilter =  THREE.NearestFilter
		position.magFilter = THREE.NearestFilter
		position.needsUpdate = true
		return position

	update:(dt)=>
		@fbo.update(dt)
		@renderMaterial.uniforms.time.value += dt/1000
		@simulationMaterial.uniforms.time.value += dt/1000
		@renderMaterial.uniforms.t_pos.value = @fbo.rt2
		@renderMaterial.uniforms.t_oPos.value = @fbo.rt3
		return

module.exports = ParticleFBO

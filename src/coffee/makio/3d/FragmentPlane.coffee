#
# Plane with a fragment shader, based on Shadertoy Model
# It also replace the shadertoy stuffs by the one need in threejs so just copy past your shadertoy :)
# By David Ronai / Makio64 / makiopolis.com
#

Stage = require("makio/core/Stage")

class FragmentPlane extends THREE.Mesh

	constructor:(fs)->
		material = @createMaterial(fs)
		geometry = @createGeometry()
		super(geometry,material)
		Stage.onUpdate.add(@update)
		return

	update:(dt)=>
		@uniforms.iGlobalTime.value += dt/1000
		return

	createMaterial:(fs)->
		@uniforms = {
			iGlobalTime: { type: "f", value: 0.0 },
			iResolution: { type: "v2", value: new THREE.Vector2(window.innerWidth,window.innerHeight) }
		}

		vs = "precision highp float; attribute vec3 position;attribute vec3 previous;attribute vec3 next;attribute float side;attribute float width;attribute vec2 uv;"
		vs += "uniform mat4 modelMatrix; uniform mat4 modelViewMatrix; uniform mat4 projectionMatrix; uniform mat4 viewMatrix; uniform mat3 normalMatrix; uniform vec3 cameraPosition;"
		vs += "void main() { gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );}"
		material = new THREE.RawShaderMaterial(
			uniforms: @uniforms
			fragmentShader: @addUniforms(fs)
			vertexShader: vs
		)
		return material

	addUniforms:(fs)->
		fs = fs.replace("void mainImage( out vec4 fragColor, in vec2 fragCoord )\n{","void main(){ vec2 fragCoord = gl_FragCoord.xy; ")
		fs = fs.replace("fragColor","gl_FragColor")
		console.log(fs)
		return "precision highp float; uniform vec2 iResolution;\nuniform float iGlobalTime;\n" + fs

	createGeometry:()->
		geometry = new THREE.PlaneGeometry(100,5)
		return geometry

	dispose:()->
		Stage3d.remove(@)
		Stage.onUpdate.remove(@update)
		@geometry.dispose()
		@material.dispose()
		return

module.exports = FragmentPlane

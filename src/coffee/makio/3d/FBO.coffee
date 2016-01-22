#
# Manage fbo, use 3 rtt to feed the position / oldposition / write
# Inpired by FBO from Nicoptere and PhysicRend from Cabbibo
# @author David Ronai / http://makiopolis.com / @makio64
#

class FBO

	constructor:( width, height, @renderer, @simulation )->

		#---------------------------------------------------------------------------------- Create Render

		options = {
			wrapS: THREE.RepeatWrapping
			wrapT: THREE.RepeatWrapping
			minFilter: THREE.NearestFilter
			magFilter: THREE.NearestFilter
			format: THREE.RGBFormat
			type: THREE.FloatType
			stencilBuffer: true
			depthBuffer: true
		}
		@rt = new THREE.WebGLRenderTarget(width, height, options)
		@rt2 = new THREE.WebGLRenderTarget(width, height, options)
		@rt3 = new THREE.WebGLRenderTarget(width, height, options)

		#---------------------------------------------------------------------------------- Create Scene

		@scene = new THREE.Scene()
		@orthoCamera = new THREE.OrthographicCamera( - 0.5, 0.5, 0.5, - 0.5, 0, 1 )
		@mesh =  new THREE.Mesh( new THREE.PlaneBufferGeometry( 1, 1 ) )
		@scene.add( @mesh )
		@copy()
		@mesh.material = @simulation
		return

	#-------------------------------------------------------------------------------------- ChangeSimulation

	setSimulation:(@simulation)->
		@mesh.material = @simulation
		@simulation.uniforms.t_pos.value = @rt3
		@simulation.uniforms.t_oPos.value = @rt2
		return

	#-------------------------------------------------------------------------------------- Update

	update:(dt)=>
		@renderer.render( @scene, @orthoCamera, @rt, false )
		tmp = @rt
		@rt = @rt2
		@rt2 = @rt3
		@rt3 = tmp
		@simulation.uniforms.t_pos.value = @rt3
		@simulation.uniforms.t_oPos.value = @rt2
		return

	#-------------------------------------------------------------------------------------- Copy

	copy:()=>
		@mesh.material = new THREE.ShaderMaterial(
			uniforms: { t_pos: { type: "t", value: @simulation.uniforms.t_pos.value } }
			vertexShader: require( "fbo/copy.vs" )
			fragmentShader: require( "fbo/copy.fs" )
		)
		@update()
		@update()
		@update()
		return

	#-------------------------------------------------------------------------------------- DEBUG

	debug:(scene)=>
		plane = new THREE.PlaneBufferGeometry( 200, 200 )
		@debug1 = new THREE.Mesh(plane, new THREE.MeshBasicMaterial(map:@rt))
		@debug2 = new THREE.Mesh(plane, new THREE.MeshBasicMaterial(map:@rt2))
		@debug3 = new THREE.Mesh(plane, new THREE.MeshBasicMaterial(map:@rt3))
		@debug2.position.x = 210
		debug3.position.x = -210
		scene.add(@debug1)
		scene.add(@debug2)
		scene.add(@debug3)
		return

module.exports = FBO

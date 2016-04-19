#
# Stage3d for threejs & wagner with every basics you need + special system for clear alpha.
# @author David Ronai / Makiopolis.com / @Makio64
#

Stage = require('makio/core/Stage')
signals = require('signals')

class Stage3d

	@camera 	= null
	@scene 		= null
	@renderer 	= null
	@isInit		= false

	# postProcess with wagner
	@postProcessInitiated 	= false
	@usePostProcessing 		= false
	@passes 				= []

	@isActivated 			= false

	@clearAuto				= false
	@clearAlpha				= 1
	@models = {}

	@init = (options)=>

		if(@isInit)
			@setColorFromOption(options)
			@activate()
			return

		@onBeforeRenderer = new signals()

		@clearColor = if options.background then options.background else 0xFF0000

		w = window.innerWidth
		h = window.innerHeight

		@resolution = new THREE.Vector2(w,h)

		@camera = new THREE.PerspectiveCamera( 50, w / h, 1, 1000000 )
		@scene = new THREE.Scene()
		@scene2 = new THREE.Scene()
		@orthoCamera = new THREE.OrthographicCamera( - 0.5, 0.5, 0.5, - 0.5, 0, 1 )
		@mesh =  new THREE.Mesh( new THREE.PlaneBufferGeometry( 1, 1 ), new THREE.MeshBasicMaterial({color:@clearColor,transparent:true,opacity:@clearAlpha}) )
		@scene2.add( @mesh )

		transparent = options.transparent||false
		antialias = options.antialias||false
		@renderer = new THREE.WebGLRenderer({alpha:transparent,antialias:antialias,preserveDrawingBuffer:false})

		console.log @renderer
		@renderer.setPixelRatio( window.devicePixelRatio )
		@renderer.domElement.className = 'three'
		@setColorFromOption(options)
		@renderer.setSize( w, h )
		@isInit = true

		@activate()
		return

	@setClearColor = (value)=>
		@clearColor = value
		@mesh.material.color = @clearColor
		@renderer.setClearColor( @clearColor,1 )
		return

	@setColorFromOption = (options)=>
		@clearAlpha = if options.clearAlpha == undefined then 1 else options.clearAlpha
		@renderer.setClearColor( parseInt(options.background), @clearAlpha )
		return

	@activate = ()=>
		if(@isActivated)
			return
		@isActivated = true
		Stage.onUpdate.add(@render)
		Stage.onResize.add(@resize)
		document.body.appendChild(@renderer.domElement)
		return

	@desactivate = ()=>
		if(!@isActivated)
			return
		@isActivated = false
		Stage.onUpdate.remove(@render)
		Stage.onResize.remove(@resize)
		document.body.removeChild(@renderer.domElement)
		return

	@initPostProcessing = ()=>

		if(@postProcessInitiated)
			return

		console.log('WAGNER PostProcess')
		@postProcessInitiated = true
		@usePostProcessing = true
		@composer = new WAGNER.Composer( @renderer, {useRGBA: true} )
		@composer.setSize( @renderer.domElement.width, @renderer.domElement.height )
		return

	@add = (obj)=>
		@scene.add(obj)
		return

	@remove = (obj)=>
		@scene.remove(obj)
		return

	@removeAll = ()=>
		while @scene.children.length>0
			@scene.remove(@scene.children[0])
		return

	@addPass = (pass)=>
		@passes.push(pass)
		return

	@removePass = (pass)=>
		for i in [0...@passes.length] by 1
			if(@passes[i]==pass)
				@passes.splice(i,1)
				break
		return

	@render = (dt)=>
		@renderer.autoClearColor = @clearColor
		@renderer.autoClear = @clearAuto
		@mesh.material.opacity = @clearAlpha

		if(@control)
			@control.update(dt)

		@onBeforeRenderer.dispatch()

		if(@usePostProcessing)
			@composer.reset()
			@composer.render( @scene2, @orthoCamera )
			@composer.toScreen()
			@composer.reset()
			@composer.render( @scene, @camera )
			for pass in @passes
				@composer.pass( pass )
			@composer.toScreen()
		else
			@renderer.clear()
			@renderer.render(@scene, @camera)
		return

	@resize = ()=>
		w = window.innerWidth
		h = window.innerHeight
		@resolution.x = w
		@resolution.y = h

		if @renderer
			@camera.aspect = w / h
			@camera.updateProjectionMatrix()
			@renderer.setSize( w, h )
			@renderer.setPixelRatio( window.devicePixelRatio )
			@render(0)
		if @composer
			@composer.setSize( @renderer.domElement.width, @renderer.domElement.height )
		return

	@initGUI = (gui)=>
		g = gui.addFolder('Camera')
		g.add(@camera,'fov',1,100).onChange(@resize)
		g.add(@camera.position,'x').listen()
		g.add(@camera.position,'y').listen()
		g.add(@camera.position,'z').listen()
		return

module.exports = Stage3d

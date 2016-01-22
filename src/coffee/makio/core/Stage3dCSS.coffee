#
# Stage3d CSS for three.js with every basics you need
# @author David Ronai / Makiopolis.com / @Makio64
#
require("CSS3DRenderer.js")
Stage = require('makio/core/Stage')

class Stage3dCSS

	@camera 	= null
	@scene 		= null
	@renderer 	= null
	@isInit		= false

	@init = (options)=>

		if(@isInit)
			return

		w = window.innerWidth
		h = window.innerHeight

		# we push the farest as possible.
		@camera = new THREE.PerspectiveCamera( 70, w / h, 1, 1000000000 )
		@scene = new THREE.Scene()

		@renderer = new THREE.CSS3DRenderer()
		@renderer.setSize( w, h )
		@renderer.domElement.className = 'stage3dCSS'

		document.body.appendChild(@renderer.domElement)
		Stage.onUpdate.add(@render)
		Stage.onResize.add(@resize)
		@resize()
		return


	@add = (obj)=>
		@scene.add(obj)
		return

	@createElement = (text,className,isSprite=true)=>
		div = document.createElement('div')
		div.className = className
		div.innerHTML = text
		if(isSprite)
			return new THREE.CSS3DSprite( div )
		else
			return new THREE.CSS3DObject( div )


	@remove = (obj)=>
		@scene.remove(obj)
		return


	@removeAll = ()=>
		while @scene.children.length>0
			@scene.remove(@scene.children[0])
		return


	@render = ()=>
		@renderer.render(@scene, @camera)
		return


	@resize = ()=>
		if @renderer
			@camera.aspect = window.innerWidth / window.innerHeight
			@camera.updateProjectionMatrix()
			@renderer.setSize( window.innerWidth, window.innerHeight )
			@render()
		return

module.exports = Stage3dCSS

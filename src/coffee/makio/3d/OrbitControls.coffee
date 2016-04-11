#
# OrbitControls using phi theta radius
# @author David Ronai / http://makiopolis.com / @makio64
#

Stage3d = require("makio/core/Stage3d")
Interactions = require('makio/core/Interactions')

class OrbitControls

	constructor:(@camera, @radius)->
		if(!@camera)
			console.warn('OrbitControls need a camera as parameter')

		@activated = false
		@offset = new THREE.Vector3()
		@target = new THREE.Vector3()
		@dragActivated = true

		@watchTarget = true
		@bouncing = true

		if(@radius == undefined || @radius == null)
			@refreshAngle()

		@_radius = @radius
		@minRadius = Number.MIN_VALUE
		@maxRadius = Number.MAX_VALUE

		@mouse = new THREE.Vector2()
		@mouseSpeed = 1
		@lastPos = new THREE.Vector2()
		@down = false

		@mouseElasticX = .1
		@mouseElasticY = .1

		@phi = Math.PI/2
		@theta = Math.PI/2
		@phiDynamic = 0
		@thetaDynamic = 0

		@isPhiRestricted = false
		@minPhi = Math.PI / 6
		@maxPhi = Math.PI / 3 * 2

		@isThetaRestricted = false
		@minTheta = Math.PI / 6
		@maxTheta = Math.PI

		@vx = 0
		@vy = 0
		@friction = 0.968
		@maxSpeed = 1



		@activate()

		return

	updateCamera:()=>
		@camera.lookAt(@target)
		return

	initGui:(gui)->
		f = gui.addFolder('OrbitControls')

		max = 12000.1
		f.add(this, '_radius',0,15000).name('radius').listen()

		p = f.addFolder('cam/target')
		p.add(@camera.position, 'x',-max,max).name('cam.x').listen()
		p.add(@camera.position, 'y',-max,max).name('cam.y').listen()
		p.add(@camera.position, 'z',-max,max).name('cam.z').listen()
		p.add(@target, 'x',-max,max).name('target.x').listen()
		p.add(@target, 'y',-max,max).name('target.y').listen()
		p.add(@target, 'z',-max,max).name('target.z').listen()

		f.open()
		return

	update:( dt )->

		# console.log(@phi, @theta)

		if(@down)
			diffX = (@mouse.x - @lastPos.x)*@mouseSpeed
			diffY = (@mouse.y - @lastPos.y)*@mouseSpeed
			@lastPos.set(@mouse.x,@mouse.y)
			@vx-=diffX*0.0004
			@vy+=diffY*0.00015

		if(@vx>@maxSpeed)
			@vx = @maxSpeed
		else if(@vx<-@maxSpeed)
			@vx = -@maxSpeed
		if(@vy>@maxSpeed)
			@vy = @maxSpeed
		else if(@vy<-@maxSpeed)
			@vy = -@maxSpeed

		@_radius += (@radius-@_radius)*0.05

		@vx *= @friction
		@vy *= @friction

		@phi 	-= @vy
		@theta 	-= @vx

		@phi %= Math.PI*2
		@theta %= Math.PI*2
		if @phi<0 then @phi+=Math.PI*2
		if @theta<0 then @theta+=Math.PI*2

		# Bouncing Back
		if(@isPhiRestricted)
			targetPhi = Math.max( @minPhi, Math.min( @maxPhi, @phi ) )
			if(@bouncing)
				@phi += (targetPhi-@phi)*.15
			else
				@phi = targetPhi

		if(@isThetaRestricted)
			targetTheta = Math.max( @minTheta, Math.min( @maxTheta, @theta ) )
			if(@bouncing)
				@theta += (targetTheta-@theta)*.15
			else
				@theta = targetTheta

		# @thetaDynamic	+=((Interactions.mouse.normalizedX-.5)*@mouseElasticX-@thetaDynamic)/10.0
		# @phiDynamic		+=((Interactions.mouse.normalizedY-.5)*-@mouseElasticY-@phiDynamic)/10.0

		# http://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates
		@camera.position.x = @offset.x + @target.x + @_radius * Math.sin( @phi ) * Math.cos( @theta )
		@camera.position.y = @offset.y + @target.y + @_radius * Math.cos( @phi )
		@camera.position.z = @offset.z + @target.z + @_radius * Math.sin( @phi ) * Math.sin( @theta )

		if(@watchTarget)
			@camera.lookAt(@target)

		return

	refreshAngle:()->

		@vx = 0
		@vy = 0

		dx = @camera.position.x - @target.x - @offset.x
		dy = @camera.position.y - @target.y - @offset.y
		dz = @camera.position.z - @target.z - @offset.z
		@radius = @_radius = @camera.position.distanceTo(@target) || 1
		@phi 	= Math.acos(dy/@_radius)
		extraTheta = if dx < 0 then Math.PI else 0

		@theta 	= Math.atan(dz/dx)+extraTheta

		@thetaDynamic = 0
		@phiDynamic = 0

		return


	setCamera:(camera)->
		@camera = camera
		@refreshAngle()
		return

	setCameraTarget:(v)->
		@target = v
		return

	activate:()->
		if @activated then return
		@activated = true
		Interactions.onDown.add(@onDown)
		Interactions.onWheel.add(@onWheel)
		return

	desactivate:()->
		if !@activated then return
		@activated = false

		Interactions.onDown.remove(@onDown)
		Interactions.onUp.remove(@onUp)
		Interactions.onMove.remove(@onMove)
		Interactions.onWheel.remove(@onWheel)
		Interactions.onLeave.remove(@onUp)
		return

	dispose:()->
		@down = false
		@desactivate()
		@target = null
		@camera = null
		return

	onDown:(e)=>
		if(!@dragActivated) then return
		@down = true
		@mouse.set(e.x, e.y)
		@lastPos.set(e.x, e.y)
		Interactions.onLeave.add(@onUp)
		Interactions.onUp.add(@onUp)
		Interactions.onMove.add(@onMove)
		return

	onUp:(e)=>
		@mouse.set(0,0)
		@down = false
		Interactions.onLeave.remove(@onUp)
		Interactions.onUp.remove(@onUp)
		Interactions.onMove.remove(@onMove)
		return

	immediate:()=>
		@_radius = @radius
		@update(10000)
		return

	onMove:(e)=>
		@mouse.set(e.x, e.y)
		return

	onWheel:( e )=>
		if( @noZoom ) then return
		if( e.delta < 0 ) then @zoomOut()
		else @zoomIn()
		return


	zoomIn:( zoomScale )->
		@radius *= .98
		if(@radius<@minRadius)
			@radius = @minRadius
		return


	zoomOut:( zoomScale )->
		@radius *= 1.05
		if(@radius>@maxRadius)
			@radius = @maxRadius
		return

module.exports = OrbitControls

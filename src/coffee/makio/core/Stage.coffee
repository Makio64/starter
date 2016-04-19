#
# Wrapper for requestAnimationFrame, Resize & Update
# @author : David Ronai / @Makio64 / makiopolis.com
#

Signal 	= require("signals")
Stats = require("stats.js")

#---------------------------------------------------------- Class Stage

class Stage

	@skipLimit		= 32
	@skipActivated  = true
	@lastTime 		= 0
	@pause 			= false

	@onResize 	= new Signal()
	@onUpdate 	= new Signal()
	@onBlur 	= new Signal()
	@onFocus 	= new Signal()

	@width 		= window.innerWidth
	@height 	= window.innerHeight

	@init:()->
		@pause = false

		window.onresize = ()=>
			@width 		= window.innerWidth
			@height 	= window.innerHeight
			@onResize.dispatch()
			return

		@lastTime = performance.now()

		requestAnimationFrame( @update )
		@stats = new Stats()
		document.body.appendChild(@stats.domElement)
		return

	@update:()=>
		t = performance.now()
		dt = t - @lastTime
		@lastTime = t
		requestAnimationFrame( @update )

		if @skipActivated && dt > @skipLimit then return
		if @pause then return

		@stats.begin()
		@onUpdate.dispatch(dt)
		@stats.end()
		return

	@init()

module.exports = Stage

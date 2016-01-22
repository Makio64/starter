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

	@init:()->
		@pause = false

		window.onresize = ()=>
			width 	= window.innerWidth
			height 	= window.innerHeight
			@onResize.dispatch()
			return

		@lastTime = performance.now()

		requestAnimationFrame( @update )
		@stat = new Stats()
		document.body.appendChild(@stat.domElement)
		@stat.domElement.style.zIndex = 1000

		return

	@update:()=>
		@stat.begin()
		t = performance.now()
		dt = t - @lastTime
		@lastTime = t
		requestAnimationFrame( @update )

		if @skipActivated && dt > @skipLimit then return
		if @pause then return

		@onUpdate.dispatch(dt)
		@stat.end()
		return

	@init()

module.exports = Stage

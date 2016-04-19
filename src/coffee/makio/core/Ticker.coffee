Stage = require('makio/core/Stage')
Signal = require('signals')

class Ticker

	constructor:(@duration, @callback, @loop = -1)->
		Stage.onUpdate.add(@update)
		@time = @duration
		@paused = false
		@onTick = new Signal
		@tickCount = 0
		return

	pause:()=>
		Stage.onUpdate.add(@update)
		@paused = true
		return @

	play:()=>
		if !@paused
			return
		@paused = false
		return

	restart:()=>
		@tickCount = 0
		return

	tick:()=>
		@onTick.dispatch(@tickCount)
		@callback(@tickCount)
		@tickCount++
		return @

	update:(dt)=>
		@time -= dt
		if(@time <= 0 && (@loop==-1||@loop>@tickCount))
			@tick()
			@time += @duration
		return

module.exports = Ticker

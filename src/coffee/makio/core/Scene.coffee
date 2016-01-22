#
# Abstract Scene
# Can have states system integrate, if you want so uncomment line 14 / 45 / 96
# @author David Ronai / Makiopolis.com / @Makio64
#

SceneTraveler = require('./SceneTraveler')

class Scene

	constructor:(@name)->
		# @startTime = 0
		# @lastTimeCheck = -1
		# @states = []
		return

	# Scene classic
	update:(dt)->
		return

	resize:()->
		return

	dispose:()->
		return

	# Transition In/Out
	transitionIn:()->
		@onTransitionInComplete()
		return

	transitionOut:()->
		@onTransitionOutComplete()
		return

	onTransitionInComplete:()->
		return

	onTransitionOutComplete:()->
		@dispose()
		SceneTraveler.onTransitionOutComplete()
		return


	###
	initState:()->
		o = {}
		for key, value of @
			if(typeof(value)!=constructor && typeof(value)!='function' && key!='states' && key!='startTime' && key!='name' && key!='lastTimeCheck')
				o[key] = value
		@changeStateAt(0,o)

		return

	# State system
	changeStateAfter:(delay, params)->
		delay *= 1000
		if(@states.length == 0)
			lastTime = 0
		else
			lastTime = @states[@states.length-1].time
		@changeStateAt((lastTime+delay)/1000, params)
		return

	changeStateAt:(time, params)->
		time *= 1000
		@states.push(time:time, params:params)
		@states.sort((a,b)->
			return a.time-b.time
		)
		return

	updateState:(time)->
		limit = time - @startTime

		if(limit < @lastTimeCheck)
			@lastTimeCheck = -1

		k = 0
		for state in @states

			if(state.time>limit)
				@lastTimeCheck = limit
				break

			if(state.time <= limit && state.time > @lastTimeCheck)
				for key, value of state.params
					if(typeof(value)=='function')
						value()
					else
						@[key] = value

			k++
		@lastTimeCheck = limit
		return
	###

module.exports = Scene

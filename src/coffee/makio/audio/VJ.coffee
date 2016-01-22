#
# - Easy way to connect midiController to Parameters
# - Analyse the music & the detect beat
# Inspired by datgui & airtightinteractive https://www.airtightinteractive.com/2013/10/making-audio-reactive-visuals
# @author : David Ronai / @Makio64 / makiopolis.com
#

gui		= require('makio/core/GUI')
Stage 	= require('makio/core/Stage')
Midi 	= require('makio/audio/Midi')
JsUtils = require('makio/utils/JsUtils')
Signal 	= require('signals')

class VJ

	@waveData = [] #waveform - from 0 - 1 . no sound is 0.5. Array [binCount]
	@levelsData = [] #levels of each frequecy - from 0 - 1 . no sound is 0. Array [levelsCount]
	@levelHistory = []

	@BEAT_HOLD_TIME = 0.17 #num of frames to hold a beat
	@BEAT_DECAY_RATE = 0.96
	@BEAT_MIN = 0.13 #level less than this is no beat

	#BPM STUFF
	@volume = 0
	@bpmTime = 0 # bpmTime ranges from 0 to 1. 0 = on beat. Based on tap bpm
	@ratedBPMTime = 550
	@count = 0
	@msecsFirst = 0
	@msecsPrevious = 0
	@msecsAvg = 633 #time between beats (msec)
	@gotBeat = false

	@levelsCount = 16 #should be factor of 512
	@beatCutOff = 0
	@beatTime = 0

	@controllers = []


	@init=(audioContext)=>
		@onBeat = new Signal()
		@analyser = audioContext.createAnalyser()
		@analyser.smoothingTimeConstant = 0.3
		@analyser.fftSize = 2048
		@binCount = @analyser.frequencyBinCount
		@levelBins = Math.floor(@binCount / @levelsCount)
		@freqByteData = new Uint8Array(@binCount)
		@timeByteData = new Uint8Array(@binCount)
		for i in [0...256]
			@levelHistory.push(0)
		return

	@mapToMidi:(obj,value,midi)=>
		switch JsUtils.type(obj[value])
			when JsUtils.TYPES.number
				return new VJNumberController(obj,value,midi)
				break
			when JsUtils.TYPES.boolean
				return new VJBooleanController(obj,value,midi)
				break
			when JsUtils.TYPES['[object Function]']
				return new VJFunctionController(obj,value,midi)
				break
		return


	@update=()=>
		if(@analyser == null)
			return

		@analyser.getByteFrequencyData(@freqByteData)
		@analyser.getByteTimeDomainData(@timeByteData)

		for i in [0...@binCount] by 1
			@waveData[i] = ((@timeByteData[i] - 128) /128 )

		for i in [0...@levelsCount] by 1
			sum = 0
			for j in [0...@levelBins] by 1
				sum += @freqByteData[(i * @levelBins) + j]
				@levelsData[i] = sum / @levelBins / 256

		@detectBeat()
		@bpmTime = (new Date().getTime() - @bpmStart)/@msecsAvg
		return

	@detectBeat = ()=>
		sum = 0
		for j in [0...@levelsCount] by 1
			sum += @levelsData[j]

		@volume = sum / @levelsCount

		@levelHistory.push(@volume)
		@levelHistory.shift(1)

		if (@volume  > @beatCutOff && @volume > @BEAT_MIN)
			# console.log("BEAT")
			@onBeat.dispatch()
			@beatCutOff = @volume *1.1
			@beatTime = 0
		else
			if (@beatTime <= @BEAT_HOLD_TIME)
				@beatTime++
			else
				@beatCutOff *= @BEAT_DECAY_RATE
				@beatCutOff = Math.max(@beatCutOff,@BEAT_MIN)
		return



class VJNumberController

	constructor:(@obj,@value,@midi)->
		@targetValue = @obj[@value]
		@min = 0
		@max = 1
		@easing = .2
		Midi.onMessage.add(@onMidi)
		Stage.onUpdate.add(@onUpdate)
		return

	minMax:(@min,@max)=>
		return

	ease:(@easing)=>
		return

	onMidi:(e)=>
		if(e.note==@midi)
			@targetValue = @min + e.velocity * (@max - @min)
			console.log(@min,e.velocity,@max,@targetValue)
			return
		return

	onUpdate:(dt)=>
		@obj[@value] +=  (@targetValue-@obj[@value])*@easing
		if(@targetValue==0 && @obj[@value] <0.01) then @obj[@value] = 0
		return

class VJBooleanController
	constructor:(@obj, @value, @midi)->
		return

	onMidi:(e)=>
		if(e.key==@midi)
			@targetValue = if e.value then 0 else 1
			return
		return

class VJFunctionController
	constructor:(@obj, @value, @midi)->
		return

	onMidi:(e)=>
		if(e.key==@midi)
			@targetValue = e.value
			return
		return

VJ.mapToMidi(VJ,'BEAT_HOLD_TIME',13).minMax(0,100)
VJ.mapToMidi(VJ,'BEAT_DECAY_RATE',14).minMax(0.9,1)
VJ.mapToMidi(VJ,'BEAT_MIN',15).minMax(0,1)

# gui.add(VJ,'BEAT_HOLD_TIME',0,100).listen()
# gui.add(VJ,'BEAT_DECAY_RATE',0.9,1).listen()
# gui.add(VJ,'BEAT_MIN',0,1).listen()

module.exports = VJ

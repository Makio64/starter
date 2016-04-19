JsUtils = require('makio/utils/JsUtils')
Midi = require('makio/audio/Midi')

gui = require('makio/core/GUI')
Stage = require('makio/core/Stage')

Signal = require('signals')

class VJ

	@waveData = [] #waveform - from 0 - 1 . no sound is 0.5. Array [binCount]
	@levelsData = [] #levels of each frequecy - from 0 - 1 . no sound is 0. Array [levelsCount]
	@levelHistory = []

	@BEAT_HOLD_TIME = .2 #num of frames to hold a beat
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

	@levelsCount = 128 #should be factor of 512
	@beatCutOff = 0
	@beatTime = 0
	@globalVolume = 1

	@controllers = []

	@init=(audioContext,@masterGain)=>
		@onBeat = new Signal()
		@controls = []
		@analyser = audioContext.createAnalyser()
		@analyser.smoothingTimeConstant = 0.3
		@analyser.fftSize = 2048
		@binCount = @analyser.frequencyBinCount
		@levelBins = Math.floor(@binCount / @levelsCount)
		@freqByteData = new Uint8Array(@binCount)
		@timeByteData = new Uint8Array(@binCount)

		for i in [0...256]
			@levelHistory.push(0)

		@globalVolume = @masterGain.gain.value
		@masterGain.connect(@analyser)

		# @mapToMidi(VJ,'BEAT_HOLD_TIME',13).minMax(0,100)
		# @mapToMidi(VJ,'BEAT_DECAY_RATE',14).minMax(0.9,1)
		# @mapToMidi(VJ,'BEAT_MIN',15).minMax(0,1)
		return

		# TESTING LED
		obj = {x:1,y:1}
		@add(obj,'x',84,Midi.XL1).minMax(0,110).onChange((v)=>
			v = Math.floor(v)
			Midi.allButton(v,Midi.PAD)
		)

		return

	# @addRadio:(group,value,midi)
	# 	return new VJBooleanController(group,value,midi)

	@add:(obj,value,midiNote,midiID,isBoolean=false)=>
		if(isBoolean)
			return new VJBooleanController(obj,value,midiNote,midiID)
		else
			return new VJNumberController(obj,value,midiNote,midiID)
		# c = new VJFunctionController(obj,value,midi)
		@controls.push(c)
		return c

	@addGroup:(buttons)=>
		for b in buttons
			b.onChange((v,d)=>
				for c in buttons
					if(d!=c)
						c.switchOff()
			)
		return

	@update=(dt)=>
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

		@detectBeat(dt)
		@bpmTime = (new Date().getTime() - @bpmStart)/@msecsAvg
		return

	@detectBeat = (dt)=>
		sum = 0
		for j in [0...@levelsCount] by 1
			sum += @levelsData[j]

		@volume = (sum / @levelsCount)*@globalVolume

		@levelHistory.push(@volume)
		@levelHistory.shift(1)

		if (@beatTime <= @BEAT_HOLD_TIME)
			@beatTime+=dt/1000
			return
		else
			@beatCutOff *= @BEAT_DECAY_RATE
			@beatCutOff = Math.max(@beatCutOff,@BEAT_MIN)

		if (@volume  > @beatCutOff && @volume > @BEAT_MIN)
			# console.log("BEAT")
			@onBeat.dispatch()
			@beatCutOff = @volume *1.1
			@beatTime = 0
		return



class VJNumberController

	constructor:(@obj,@value,@midi,@id)->
		@_onChange = new Signal()
		@targetValue = @obj[@value]
		@min = 0
		@max = 1
		@easing = .2
		@easingFunction = null#(t)-> return t;
		Midi.onMessage.add(@onMidi)
		Stage.onUpdate.add(@onUpdate)
		return

	minMax:(@min,@max)=>
		return @

	ease:(@easing,easingFunction)=>
		if(easingFunction)
			@easingFunction = easingFunction
		return @

	onMidi:(e)=>
		if(e.note==@midi && e.id == @id.in)
			@targetValue = @min + e.velocity * (@max - @min)
			@_onChange.dispatch(@targetValue)
			return
		return

	onUpdate:(dt)=>
		if(@easingFunction)
			t = @easingFunction(@targetValue)
		else
			t = @targetValue
		@obj[@value] +=  (t-@obj[@value])*@easing
		if(t==0 && @obj[@value] <0.01) then @obj[@value] = 0
		return

	onChange:(@onChangeCB)=>
		@_onChange.add(@onChangeCB)
		return @

class VJBooleanController extends VJNumberController
	constructor:(@obj, @value, @midi, @id, @switchMode=true)->
		super(@obj, @value, @midi, @id)
		@easing = 1
		@isOn = (@obj[@value] == 1 || @obj[@value] == true)
		if(@isOn)
			Midi.yellowLed(@midi,@id)
		else
			Midi.amberLed(@midi,@id)
		return @

	onMidi:(e)=>
		if(e.note==@midi && e.id == @id.in && e.velocity==1)
			if(@switchMode)
				@isOn = !@isOn
				@switchTo(@isOn)
		return

	switchOff:()=>
		@isOn = false
		Midi.amberLed(@midi,@id)
		@targetValue = 0
		@_onChange.dispatch(@targetValue,@)
		return @

	switchOn:()=>
		@isOn = true
		Midi.yellowLed(@midi,@id)
		@targetValue = 1
		@_onChange.dispatch(@targetValue,@)
		return @

	switchTo:(value)=>
		if value
			@switchOn()
		else
			@switchOff()
		return @


class VJFunctionController extends VJNumberController
	constructor:(@obj, @value, @midi)->
		Midi.onMessage.add(@onMidi)
		return

	onMidi:(e)=>
		if(e.note==@midi)
			if e.type==128
				@obj[@value]()
		return

module.exports = VJ

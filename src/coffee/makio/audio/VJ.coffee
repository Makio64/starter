JsUtils = require('makio/utils/JsUtils')
Midi = require('makio/audio/Midi')

gui = require('makio/core/GUI')
Stage = require('makio/core/Stage')

Signal = require('signals')

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
		@mapToMidi(VJ,'BEAT_HOLD_TIME',13).minMax(0,100).onChange(()=>
			console.log('beat_hold')
		)
		@mapToMidi(VJ,'BEAT_DECAY_RATE',14).minMax(0.9,1)
		@mapToMidi(VJ,'BEAT_MIN',15).minMax(0,1)

		return

	@mapToMidi:(obj,value,midi,isBoolean=false)=>
		if(isBoolean)
			return new VJBooleanController(obj,value,midi)
		else
			return new VJNumberController(obj,value,midi)
		# c = new VJFunctionController(obj,value,midi)
		@controls.push(c)
		return c


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
		if(e.note==@midi)
			@targetValue = @min + e.velocity * (@max - @min)
			if @onChangeCB then @onChangeCB(@targetValue)
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
		return @

class VJBooleanController extends VJNumberController
	constructor:(@obj, @value, @midi, @switchMode=true)->
		super(@obj, @value, @midi)
		@easing = 1
		@isOn = (@obj[@value] == 1 || @obj[@value] == true)
		if(@isOn)
			Midi.yellowLed(@midi)
		else
			Midi.amberLed(@midi)
		return

	onMidi:(e)=>
		if(e.note==@midi)
			if(@switchMode)
				if e.type==128
					@isOn = !@isOn
					if @isOn
						Midi.yellowLed(@midi)
					else
						Midi.amberLed(@midi)
					@targetValue = if @isOn then 0 else 1
					if @onChangeCB then @onChangeCB(@targetValue)
		return

class VJFunctionController extends VJNumberController
	constructor:(@obj, @value, @midi)->
		Midi.onMessage.add(@onMidi)
		return

	onMidi:(e)=>
		if(e.note==@midi)
			if e.type==128
				@obj[@value]()
		return


# gui.add(VJ,'BEAT_HOLD_TIME',0,100).listen()
# gui.add(VJ,'BEAT_DECAY_RATE',0.9,1).listen()
# gui.add(VJ,'BEAT_MIN',0,1).listen()

module.exports = VJ

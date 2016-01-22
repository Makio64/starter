#
# 'Simple' audio system
# @author David Ronai / http://makiopolis.com / @makio64
#

signals			= require('signals')
gui				= require('core/GUI').gui

class Audio

	@init:()=>
		window.AudioContext = window.AudioContext || window.webkitAudioContext

		@context = new AudioContext()
		@masterGain = @context.createGain()
		@masterGain.gain.value = 1.0

		@bufferSize = 2048

		@pitchShifterActivated = true
		@pitchLevel = 1
		@osamp = 4

		gui.add(@masterGain.gain,'value',0,1).name('volume')

		@mainAnalyser = @createAnalyser()
		@fxAnalyser = @createAnalyser()
		@pitchAnalyser = @createAnalyser()

		#SoundFX
		@soundFX = []

		# Filters Biquad Filter
		@lowPass = @context.createBiquadFilter()
		@lowPass.type = 'lowpass'
		@lowPass.frequency.value = 836
		@soundFX.push(@lowPass)

		@highPass = @context.createBiquadFilter()
		@highPass.type = 'highpass'
		@highPass.frequency.value = 200
		@soundFX.push(@highPass)

		@bandPass = @context.createBiquadFilter()
		@bandPass.type = 'bandpass'
		@bandPass.frequency.value = 256
		@soundFX.push(@bandPass)

		@lowShelfPass = @context.createBiquadFilter()
		@lowShelfPass.type = 'lowshelf'
		@lowShelfPass.frequency.value = 200
		@soundFX.push(@lowShelfPass)

		@highShelfPass = @context.createBiquadFilter()
		@highShelfPass.type = 'highshelf'
		@highShelfPass.frequency.value = 200
		@soundFX.push(@highShelfPass)

		@peakingPass = @context.createBiquadFilter()
		@peakingPass.type = 'peaking'
		@peakingPass.frequency.value = 200
		@soundFX.push(@peakingPass)

		@notchPass = @context.createBiquadFilter()
		@notchPass.type = 'notch'
		@notchPass.frequency.value = 200
		@soundFX.push(@notchPass)

		@allPass = @context.createBiquadFilter()
		@allPass.type = 'allpass'
		@allPass.frequency.value = 200
		@soundFX.push(@allPass)

		for pass in @soundFX
			pass.isConnected = false
			pass.useIt = false

		@lowPass.useIt = true

		gui.add(@,'pitchLevel',.1,2).step(.1)
		gui.add(@,'pitchShifterActivated').name('pitchShift').onChange(@update)
		gui.add(@,'osamp',[1,2,4])
		g = gui.addFolder('Biquad Filters')
		g.add(@bandPass,'useIt').name('band').onChange(@update)
		g.add(@bandPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@highPass,'useIt').name('high').onChange(@update)
		g.add(@highPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@lowPass,'useIt').name('low').onChange(@update)
		g.add(@lowPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@lowShelfPass,'useIt').name('lowShelf').onChange(@update)
		g.add(@lowShelfPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@highShelfPass,'useIt').name('highShelf').onChange(@update)
		g.add(@highShelfPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@peakingPass,'useIt').name('peaking').onChange(@update)
		g.add(@peakingPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@notchPass,'useIt').name('notch').onChange(@update)
		g.add(@notchPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)
		g.add(@allPass,'useIt').name('all').onChange(@update)
		g.add(@allPass.frequency,'value',0,@bufferSize).name('freq').onChange(@update)

		@pitchShifterProcessor = @createPitchShifter()
		@update()
		return

	@createAnalyser:()=>
		analyser = @context.createAnalyser()
		analyser.fftSize = @bufferSize
		@binCount = analyser.frequencyBinCount
		return analyser

	@update:(value)=>
		@masterGain.disconnect()
		@pitchShifterProcessor.disconnect()

		@obj = @masterGain
		if(@pitchShifterProcessor && @pitchShifterActivated)
			@obj.connect(@pitchShifterProcessor)
			@pitchShifterProcessor.connect(@pitchAnalyser)
			@obj = @pitchShifterProcessor

		for pass in @soundFX
			if(pass.useIt)
				@obj.connect(pass)
				pass.isConnected = true
				@obj = pass
			else if(pass.isConnected)
				pass.disconnect()
			pass.isConnected = false

		@obj.connect(@context.destination)
		@obj.connect(@fxAnalyser)
		@masterGain.connect(@mainAnalyser)
		return

	@hannWindow:(length)->
		array = new Float32Array(length)
		for i in [0...length] by 1
			array[i] = 0.5 * (1 - Math.cos(2 * Math.PI * i / (length - 1)))
		return array

	@linearInterpolation:(a, b, t)->
		return a + (b - a) * t


	@init()

	constructor:( url=null )->
		@isStop = true
		@onLoadComplete = new signals()
		@gainNode = Audio.context.createGain()
		@gainNode.gain.value = 1.0
		@gainNode.connect(Audio.masterGain)
		if( url )
			@load( url )
		return

	load:( url )=>
		@request = new XMLHttpRequest()
		@request.open( "GET", url, true )
		@request.responseType = "arraybuffer"
		@request.onload = @onLoad
		@request.send()
		return

	onLoad:()=>
		Audio.context.decodeAudioData( @request.response, ( buffer ) =>
			@buffer = buffer
			@start()
			@onLoadComplete.dispatch()
		, ()=>
			console.log('error decoding the audio data')
		)
		return

	start:()=>
		@seek( 0 )
		return

	stop:()=>
		if(@source && !@isStop)
			@isStop = true
			@source.stop(0)
			@source.disconnect(@gainNode)
		return

	playbackRate:(value)=>
		if(@source)
			@source.playbackRate.value = value
		return

	setPosition3d:(x,y,z)=>
		if(!@is3d)
			@source.disconnect()
			@pannerNode = Audio.context.createPanner()
			@pannerNode.connect(@gainNode)
			@source.connect(@pannerNode)
			@is3d=true
		@pannerNode.setPosition(x, y, z)
		return

	setVolume:(value)=>
		#crossfading more smooth
		value = Math.cos(value * 0.5*Math.PI)
		@gainNode.gain.value = value
		return


	seek:(time)=>
		@stop()
		@isStop = false
		@source = Audio.context.createBufferSource()
		@source.loop = true
		@source.buffer = @buffer
		if(@is3d)
			@source.connect( @pannerNode )
		else
			@source.connect( @gainNode )
		@source.start( 0, time/1000 )
		return

module.exports = Audio

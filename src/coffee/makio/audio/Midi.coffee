#
# Provide easy way to connect to the midi controler
# @author : David Ronai / @Makio64 / makiopolis.com
#

Signal = require('signals')

class Midi

	@onInit = new Signal()
	@onMessage = new Signal()

	@init=()=>
		if(navigator.requestMIDIAccess)
			navigator.requestMIDIAccess({sysex: false}).then(@onMIDISuccess, @onMIDIFailure)
		else
			alert("No MIDI support in your browser.")
		return

	@onMIDISuccess=(midiAccess)=>
		detected = 0
		@midi = midiAccess
		@inputs = []
		@outputs = []
		for i in [0...@midi.inputs.size]
			input = @midi.inputs.values().next()
			output = @midi.outputs.values().next().value
			input.value.onmidimessage = @onMIDIMessage
			@inputs.push(input)
			@outputs.push(output)
		console.log('midi controllers input / ouput ',@midi.inputs.size,@midi.outputs.size)
		@allButton(15)
		@onInit.dispatch()
		return

	@onMIDIFailure=(error)=>
		console.log("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + error)
		return

	@onMIDIMessage=(message)=>
		data = message.data
		cmd = data[0] >> 4
		channel = data[0] & 0xf
		type = data[0] & 0xf0
		note = data[1]
		velocity = data[2]/127
		s = ''
		s += 'cmd: '+cmd+'<br />'
		s += 'channel: '+channel+'<br />'
		s += 'type: '+type+'<br />'
		s += 'note: '+note+'<br />'
		s += 'velocity: '+velocity+'<br />'
		div = document.querySelector('#content')
		div.innerHTML = s

		console.log("NOTE:",note)
		@onMessage.dispatch({data:data,cmd:cmd,channel:channel,type:type,note:note,velocity:velocity})
		return

	# Send message to control midi ( light for example )
	@sendMessage=(note,value)=>
		if(note >= 41 )
			@outputs[0].send( [144,note,value] )
		else
			@outputs[0].send( [240, 0, 32, 41, 2, 17, 120, 0, note, value, 247] )
		return

	@allButton=(value)=>
		for i in [0...4]
			@sendMessage(41+i, value)
			@sendMessage(73+i, value)
			@sendMessage(57+i, value)
			@sendMessage(89+i, value)
		return

	@greenLed=(note)=>
		# 28 / 60
		Midi.sendMessage(note,60)
		return

	@redLed=(note)=>
		# 13 / 15
		Midi.sendMessage(note,15)
		return

	@yellowLed=(note)=>
		Midi.sendMessage(note,62)
		return

	@amberLed=(note)=>
		# 29
		Midi.sendMessage(note,29)
		return

	@offLed=(note)=>
		Midi.sendMessage(note,12)
		return

	@init()


module.exports = Midi

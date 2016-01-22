# 
# Provide easy way to connect to the midi controler
# @author : David Ronai / @Makio64 / makiopolis.com
#

Signal = require('signals')

class Midi

	@onMessage = new Signal()

	@init=()=>
		if(navigator.requestMIDIAccess)
			navigator.requestMIDIAccess({
				sysex: false
			}).then(@onMIDISuccess, @onMIDIFailure)
		else
			alert("No MIDI support in your browser.")
		return

	@onMIDISuccess=(midiAccess)=>
		detected = 0
		midi = midiAccess
		input = midi.inputs.values().next()
		if(input.value && !input.done)
			detected++
			input.value.onmidimessage = @onMIDIMessage
			input = midi.inputs.values().next()
		console.log('midi controllers detected',detected)
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


module.exports = Midi

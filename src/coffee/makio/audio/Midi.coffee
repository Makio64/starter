#
# Provide easy way to connect to the midi controler
# @author : David Ronai / @Makio64 / makiopolis.com
#

Signal = require('signals')

class Midi

	@onInit = new Signal()
	@onMessage = new Signal()

	@XL1 = {in:'-909041163',out:'606894372',type:'xl'}
	@XL2 = {in:'1764102944',out:'-1845450469',type:'xl'}
	@PAD = {in:'879598748',out:'-324232190',type:'pad'}

	@init=()=>
		@domElement = document.createElement('div')
		@domElement.className = 'midi'
		# document.body.appendChild @domElement
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

		@midi.inputs.forEach( ( port, key )=>
			# console.log('midi in', port.id, port.name)
			# console.log(port)
			input = port
			input.onmidimessage = @onMIDIMessage
			@inputs.push(input)
		)

		@midi.outputs.forEach( ( port, key )=>
			# console.log('midi out', port.id, port.name)
			@outputs.push(port)
		)

		console.log('[MIDI] INIT:',@midi.inputs.size,@midi.outputs.size)
		@allButton(15,@XL1)
		@allButton(15,@XL2)
		@allButton(5,@PAD)
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
		id = message.target.id
		s = ''
		s += 'cmd: '+cmd+'<br />'
		s += 'channel: '+channel+'<br />'
		s += 'type: '+type+'<br />'
		s += 'note: '+note+'<br />'
		s += 'velocity: '+velocity+'<br />'
		@domElement.innerHTML = s
		console.log("NOTE:",note)
		@onMessage.dispatch({id:id,data:data,cmd:cmd,channel:channel,type:type,note:note,velocity:velocity})
		return

	# Send message to control midi ( light for example )
	@sendMessage=(note,value,id)=>
		for i in [0...@outputs.length]
			if(@outputs[i].id!=id.out)
				continue
			if(note >= 41 || id.type == 'pad' )
				@outputs[i].send( [144,note,value] )
			else
				@outputs[i].send( [240, 0, 32, 41, 2, 17, 120, 0, note, value, 247] )
		return

	@allButton=(value,id)=>
		if(id.type == 'xl')
			for i in [0...4]
				@sendMessage(41+i, value,id)
				@sendMessage(73+i, value,id)
				@sendMessage(57+i, value,id)
				@sendMessage(89+i, value,id)
		else
			for x in [1..9]
				for y in [1..8]
					@sendMessage(x+y*10, value, id)
				# if(x<9)
				# 	@sendMessage(x+104, value, id)
		return

	@greenLed=(note,id)=>
		# 28 / 60
		Midi.sendMessage(note,60,id)
		return

	@redLed=(note,id)=>
		# 13 / 15
		if(id.type=='pad')
			Midi.sendMessage(note,5,id)
		else
			Midi.sendMessage(note,15,id)
		return

	@yellowLed=(note,id)=>
		Midi.sendMessage(note,62,id)
		return

	@amberLed=(note,id)=>
		# 29
		# console.log(note,id)
		if(id.type=='pad')
			Midi.sendMessage(note,1,id)
		else
			Midi.sendMessage(note,29,id)
		return

	@offLed=(note,id)=>
		Midi.sendMessage(note,12,id)
		return

module.exports = Midi

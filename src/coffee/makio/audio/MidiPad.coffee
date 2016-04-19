Midi = require 'makio/audio/Midi'
Interactions = require 'makio/core/Interactions'

class MidiPad

    constructor:()->
        @createUI()
        return

    createUI:()->
        domElement = document.createElement('div')
        domElement.className = 'gui-pad'

        keys = "12345678qwertyuiasdfghjkzxcvbnm¼".toLowerCase().split('')

        @touchs = []

        for y in [0...8]
            for x in [0...8]
                id = x+y*8
                altKey = id > 64
                ctrlKey = id > 32 && !altKey
                id %= 32
                touch = new PadTouch(id,81,keys[id])
                touch.altKey = altKey
                touch.ctrlKey = ctrlKey
                domElement.appendChild touch.domElement
                @touchs.push touch

        Interactions.onKeyDown.add(@onKeyDown)
        # document.body.appendChild(domElement)
        return

    switchOn:(letter,altKey=false)=>
        for t in @touchs
            if t.letter == letter && t.altKey == altKey
                t.switchOn()
        return

    switchOff:(letter,altKey=false)=>
        for t in @touchs
            if t.letter == letter && t.altKey == altKey
                t.switchOff()
        return

    add:(letter,midiTouch,altKey=false)=>
        for t in @touchs
            if t.letter == letter && t.altKey == altKey
                t.activate(midiTouch)
                return
        return

    onKeyDown:(e)=>
        altKey = Interactions.altKey
        ctrlKey = Interactions.ctrlKey
        letter = String.fromCharCode(e).toLowerCase()
        for t in @touchs
            if t.letter == letter && t.altKey == altKey && t.ctrlKey == ctrlKey
                t.onClickBt(null)
                return
        return

class PadTouch

    constructor:(@id,@midiID,@letter)->
        @altKey = false
        @ctrlKey = false
        @domElement = document.createElement('div')
        @domElement.addEventListener('mouseup',@onClickBt)
        @domElement.innerHTML = @letter
        @domElement.style.backgroundColor = '#F00'
        @isActivated = false
        return

    activate:(@midi)=>
        @isActivated = true
        @domElement.style.backgroundColor = '#666'
        return @midi

    switchOn:()=>
        if !@isActivated then return
        if(!@midi.isOn)
            @midi.switchOn()
        return

    switchOff:()=>
        if !@isActivated then return
        if(@midi.isOn)
            @midi.switchOff()
        return

    onClickBt:(e)=>
        if !@isActivated then return
        if(@midi.isOn)
            @midi.switchOff()
            @domElement.style.backgroundColor = '#666'
        else
            @midi.switchOn()
            @domElement.style.backgroundColor = '#0FF'
        return

module.exports = MidiPad

#
# BorderLoader
#
# Css/JS Loader using the border of the screen
# By David Ronai / Makio64 / makiopolis.com
#

Stage = require "makio/core/Stage"

class BorderLoader

	constructor:()->
		@top = @createDiv('topBorder')
		@bottom = @createDiv('bottomBorder')
		@right = @createDiv('rightBorder')
		@left = @createDiv('leftBorder')
		@percent = 0
		return

	createDiv:(className='')->
		div = document.createElement('div')
		div.className = className
		document.body.appendChild(div)
		return div

	setPercent:(value)->
		@percent = value
		v = Math.min(value*4, 1)
		@top.style.transform = 'scaleX('+v+')';
		v = Math.min(Math.max(0,value - 0.25)*4, 1);
		@right.style.transform = 'scaleY('+v+')';
		v = Math.min(Math.max(0,value - 0.5)*4, 1);
		@bottom.style.transform = 'scaleX('+v+')';
		v = Math.min(Math.max(0,value - 0.75)*4, 1);
		@left.style.transform = 'scaleY('+v+')';
		return

	hide:(autodispose = true)=>
		if(@hidePercent)
			return
		@top.className += ' hide'
		@bottom.className += ' hide'
		@right.className += ' hide'
		@left.className += ' hide'
		@hidePercent = 0
		Stage.onUpdate.add(@hiding)
		return

	hiding:(dt)=>
		@hidePercent += (1-@hidePercent)*(0.08*dt/16)
		v = 1 - @hidePercent
		v2 = @hidePercent + 1
		if(v<0.01)
			v = 0.01
			Stage.onUpdate.remove(@hiding)
			@dispose()

		@top.style.transform = 'scaleY('+v+') scaleX('+v2+')';
		@right.style.transform = 'scaleX('+v+')  scaleY('+v2+')';
		@bottom.style.transform = 'scaleY('+v+')  scaleX('+v2+')';
		@left.style.transform = 'scaleX('+v+') scaleY('+v2+')';

		return

	dispose:()=>
		document.body.removeChild(@top)
		document.body.removeChild(@bottom)
		document.body.removeChild(@left)
		document.body.removeChild(@right)
		return

module.exports = BorderLoader

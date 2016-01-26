Stage = require "makio/core/Stage"
BorderLoader = require "makio/ui/BorderLoader"

#---------------------------------------------------------- Class Loader

class Preloader

	@percent = 0

	@fakeLoad = (dt)=>
		@percent += 0.0004*dt/32
		@loaderBorder.setPercent(@loaderBorder.percent + (@percent-@loaderBorder.percent)*0.15)

	@init = ()=>
		document.removeEventListener('DOMContentLoaded', Preloader.init)
		l = document.createElement('div')
		l.className = 'loading'
		document.body.appendChild(l)
		@loaderBorder = new BorderLoader()
		@loaderBorder.setPercent(0)

		Stage.onUpdate.add(@fakeLoad)

		require.ensure(['Main'], (require)=>
			Main = require('Main')
			main = new Main(@onLoad)
			test = (dt)=>
				if(dt>100) then return
				if(@loaderBorder.percent>=1.00)
					Stage.onUpdate.remove(@fakeLoad)
					Stage.onUpdate.remove(test)
					@loaderBorder.setPercent(1)

			Stage.onUpdate.add(test)
		)
		return

	@onLoad:(percent)=>
		if(percent > @percent)
			@percent = percent
		if(percent == 1)
			setTimeout(()=>
				loader = document.querySelector(".loading")
				loader.className += ' hideOut'
				@loaderBorder.hide(true)
				setTimeout(()=>
					document.querySelector(".loading").parentNode.removeChild(loader)
				,1000)
			,700)
		return

	document.addEventListener('DOMContentLoaded', Preloader.init)

module.exports = Preloader

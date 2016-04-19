class AudioTexture extends THREE.DataTexture

	constructor:(@length, @history)->
		@index = 0
		@data = new Float32Array(@length * @history)

		for i in [0...@data.length] by 1
			@data[i] = 0

		super( @data, @length, @history, THREE.LuminanceFormat, THREE.FloatType, THREE.RepeatWrapping, THREE.RepeatWrapping, THREE.RepeatWrapping )
		@minFilter =  THREE.NearestFilter
		@magFilter = THREE.NearestFilter
		@needsUpdate = true
		return

	update:(data)->

		for i in [@history-1..1] by -1
			for j in [@length-1..0] by -1
				@data[(i*data.length+j)+1] = @data[ ((i-1)*data.length+j)+1 ]

		for i in [0...data.length] by 1
			@data[ i+1 ] = data[i]/256

		@needsUpdate = true
		return

module.exports = AudioTexture

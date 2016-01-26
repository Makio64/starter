class AudioTexture extends THREE.DataTexture

	constructor:(@length, @history)->
		@index = 0
		@data = new Float32Array(@length * @history * 3)

		for i in [0...@data.length] by 1
			@data[i] = 0

		super( @data, @length, @history, THREE.RGBFormat, THREE.FloatType, THREE.RepeatWrapping, THREE.RepeatWrapping, THREE.RepeatWrapping )
		@minFilter =  THREE.LinearFilter
		@magFilter = THREE.NearestFilter
		@needsUpdate = true
		return

	update:(data)->

		for i in [@history-1..1] by -1
			for j in [@length-1..0] by -1
				@data[(i*data.length+j)*3+1]	 = @data[ ((i-1)*data.length+j)*3+1 ]
				@data[(i*data.length+j)*3+2] = @data[ ((i-1)*data.length+j)*3+2 ]
				@data[(i*data.length+j)*3+3] = @data[ ((i-1)*data.length+j)*3+3 ]

		for i in [0...data.length] by 1
			@data[ i*3+1 ] = data[i]
			@data[ i*3+2 ] = data[i]
			@data[ i*3+3 ] = data[i]


		@needsUpdate = true
		return

module.exports = AudioTexture

class Random

	@floatArray = ( size, range )->
		array = new Float32Array( size )
		for i in [0...size]
			array[size] = ( Math.random()-.5 ) * range
		return array

	@between=(min,max)->
		return min+Math.random()*(max-min)

	@choice=(choice1,choice2)->
		return (if Math.random()<.5 then choice1 else choice2)

	@pickIn=(array)->
		return array[Math.floor(Math.random()*array.length)]

	@shuffleArray = (array)->
		l = array.length
		for i in [0...l] by 1
			j = Math.floor(Math.random() * l)
			temp = array[i]
			array[i] = array[j]
			array[j] = temp
			
		return array;

	@shuffleArrayVec3 = (array)->
		l = array.length/3
		for k in [0...l] by 1
			i = k*3
			j = Math.floor(Math.random() * l)*3

			temp = array[i]
			array[i] = array[j]
			array[j] = temp

			temp = array[i+1]
			array[i+1] = array[j+1]
			array[j+1] = temp

			temp = array[i+2]
			array[i+2] = array[j+2]
			array[j+2] = temp

		return array;


module.exports = Random

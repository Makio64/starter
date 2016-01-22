#
# Common Random need in many projects
# By David Ronai / Makio64 / makiopolis.com
#

class Random

	@data=( width, height, size )->
		l = width * height * 3
		data = new Float32Array( l )
		while( l-- )
			data[l] = ( Math.random()-.5 ) * size
		return data

	@between=(min,max)->
		return min+Math.random()*(max-min)

	@choice=(choice1,choice2)->
		return (if Math.random()<.5 then choice1 else choice2)

	@shuffleArray = (array)->
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

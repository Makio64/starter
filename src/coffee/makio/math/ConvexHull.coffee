#
# ConvexHullPoint
#
# Algorythme to find the convex shape of an array of points
# @author David Ronai / Makiopolis.com / @Makio64
#

class ConvexHullPoint

	constructor:(@index, @angle, @distance)->
		return

	compare:(p)=>
		if(@angle < p.angle)
			return -1
		else if(@angle > p.angle)
			return 1
		else
			if(@distance < p.distance)
				return -1
			  else if(@distance > p.distance)
				return 1
		return 0

class ConvexHull

	@ccw = (p1, p2, p3)->
		return (@points[p2][@x]-@points[p1][@x])*(@points[p3][@y]-@points[p1][@y])-(@points[p2][@y]-@points[p1][@y])*(@points[p3][@x]-@points[p1][@x])

	@angle = (o, a)->
		return Math.atan((@points[a][@y]-@points[o][@y])/(@points[a][@x]-@points[o][@x]))

	@distance = (a, b)->
		return (@points[b][@x]-@points[a][@x])*(@points[b][@x]-@points[a][@x])+(@points[b][@y]-@points[a][@y])*(@points[b][@y]-@points[a][@y])

	@compute = (@points,@x="x",@y="y")->
		if @points.length < 3
			throw new Error('the array should have at the minimum 3 points')
			return

		min = 0
		for i in [1...@points.length] by 1
			if(@points[i][@y] == @points[min][@y])
				if(@points[i][@x] < @points[min][@x])
					min = i
			else if(@points[i][@y] < @points[min][@y])
				min = i

		al = new Array()
		ang = 0.0
		dist = 0
		for i in [0...@points.length] by 1
			if(i == min)
				continue
			ang = @angle(min, i)
			if(ang < 0)
				ang += Math.PI
			dist = @distance(min, i)
			al.push(new ConvexHullPoint(i, ang, dist))

		al.sort((a, b)->
			return a.compare(b)
		)

		stack = new Array(@points.length + 1)
		j = 2
		for i in [0...@points.length] by 1
			if(i == min)
				continue
			stack[j] = al[j-2].index
			j++

		stack[0] = stack[@points.length]
		stack[1] = min

		M = 2
		for i in [3..@points.length] by 1
			while(@ccw(stack[M-1], stack[M], stack[i]) <= 0)
				M--
			M++
			tmp = stack[i]
			stack[i] = stack[M]
			stack[M] = tmp

		@indices = new Array(M)
		for i in [0...M] by 1
			@indices[i] = stack[i + 1]

		return @indices

module.exports = ConvexHull

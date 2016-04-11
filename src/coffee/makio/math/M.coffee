#
# MathExtra
#
# Extra Math need in many project
# @author David Ronai / Makiopolis.com / @Makio64
#

class M

	constructor:()->
		throw new Error('you cant instanciate M')
		return

	@nextPowerTwo:(value)->
		power = 0
		while(value > Math.pow(2,power))
			power++
		return Math.pow(2,power)

	@smoothstep:(min, max, value)->
		x = Math.max(0, Math.min(1,(value-min)/(max-min)))
		return x*x*(3 - 2*x)

	@distance:(p,p2)->
		dx = p.x-p2.x
		dy = p.y-p2.y
		return dx*dx+dy*dy

	@distanceSqrt:(p,p2)->
		dx = p.x-p2.x
		dy = p.y-p2.y
		if(p.z)
			dz = p.z-p2.z
			return Math.sqrt(dx*dx+dy*dy+dz*dz)
		return Math.sqrt(dx*dx+dy*dy)

	@orbitPosition:( phi, theta, radius)->
		return new THREE.Vector3(
			radius * Math.sin( phi ) * Math.cos( theta ),
			radius * Math.cos( phi ),
			radius * Math.sin( phi ) * Math.sin( theta )
		)

	@mix:(value1,value2,percent)->
		return value1*(1-percent)+value2*percent

	@remap:(value, low1, high1, low2, high2, clamp = true) ->
		n = low2 + (high2 - low2) * (value - low1) / (high1 - low1)
		if clamp
			if low2 < high2
				return Math.min(Math.max(n, low2), high2)
			else
				return Math.max(Math.min(n, low2), high2)
		else
			return n

	@lineIntersect:(startX1, startY1, endX1, endY1, startX2, startY2, endX2, endY2)->
		denominator = ((endY2 - startY2) * (endX1 - startX1)) - ((endX2 - startX2) * (endY1 - startY1))
		if (denominator == 0)
			return null
		a = startY1 - startY2
		b = startX1 - startX2
		numerator1 = ((endX2 - startX2) * a) - ((endY2 - startY2) * b)
		numerator2 = ((endX1 - startX1) * a) - ((endY1 - startY1) * b)
		a = numerator1 / denominator
		b = numerator2 / denominator
		x = startX1 + (a * (endX1 - startX1))
		y = startY1 + (a * (endY1 - startY1))
		return {x:x,y:y}


module.exports = M

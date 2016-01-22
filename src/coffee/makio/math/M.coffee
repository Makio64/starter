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
		return Math.sqrt(dx*dx+dy*dy)

	@orbitPosition:( phi, theta, radius)->
		return new THREE.Vector3(
			radius * Math.sin( phi ) * Math.cos( theta ),
			radius * Math.cos( phi ),
			radius * Math.sin( phi ) * Math.sin( theta )
		)

module.exports = M

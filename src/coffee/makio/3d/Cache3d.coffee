#
# Cache3D to avoid creating many time the same geometry
# @author David Ronai / http://makiopolis.com / @makio64
#
class Cache3D

	@caches : {}

	@plane = (w=1,h=1,segment=1,rotationX=0)=>
		if(!@caches["plane_#{w}_#{h}_#{segment}_#{rotationX}"])
			geo = new THREE.PlaneBufferGeometry( w, h, segment, segment )
			if(rotationX!=0)
				m = new THREE.Matrix4
				m.makeRotationX(rotationX)
				geo.applyMatrix(m)
			@caches["plane_#{w}_#{h}_#{segment}_#{rotationX}"] = geo
		return @caches["plane_#{w}_#{h}_#{segment}_#{rotationX}"]

	@cube = (w=1,h=1,d=1)=>
		if(!@caches["cube_#{w}_#{h}_#{d}"])
			@caches["cube_#{w}_#{h}_#{d}"] = new THREE.CubeGeometry( w, h, d )
		return @caches["cube_#{w}_#{h}_#{d}"]

	@sphere = (r=1,ws=8,hs=8,phi=0,phiLength=Math.PI*2,theta=0,thetaLength=Math.PI)=>
		if(!@caches["sphere_#{r}_#{ws}_#{hs}_#{phi}_#{phiLength}_#{theta}_#{thetaLength}"])
			@caches["sphere_#{r}_#{ws}_#{hs}_#{phi}_#{phiLength}_#{theta}_#{thetaLength}"] = new THREE.SphereGeometry( r, ws, hs, phi, phiLength, theta, thetaLength )
		return @caches["sphere_#{r}_#{ws}_#{hs}_#{phi}_#{phiLength}_#{theta}_#{thetaLength}"]

	@cylinder = (radiusTop=1, radiusBottom=1, height=1, radiusSegments=8, heightSegments=1, openEnded=false) =>
		if(!@caches["cylinder_#{radiusTop}_#{radiusBottom}_#{height}_#{radiusSegments}"])
			@caches["cylinder_#{radiusTop}_#{radiusBottom}_#{height}_#{radiusSegments}"] = new THREE.CylinderGeometry( radiusTop, radiusBottom, height, radiusSegments, heightSegments, openEnded )
		return @caches["cylinder_#{radiusTop}_#{radiusBottom}_#{height}_#{radiusSegments}"]

	# TODO Other Geometry

	disposeAll = ()=>
		for key of @caches
			@caches[key].dispose()
		@caches = {}
		return

module.exports = Cache3D

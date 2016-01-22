#
# Simple Mesh Line Wrapper + Line utility
# By David Ronai / Makio64 / makiopolis.com
#

require("THREE.MeshLine")

Stage3d 		= require("makio/core/Stage3d")

class Line extends THREE.Mesh

	constructor:(points, options={})->

		line = new THREE.MeshLine()
		line.setGeometry( points )

		options.color ?= Math.floor(Math.random()*0xFFFFFF)
		options.width ?= 10
		options.opacity ?= 1

		material = new THREE.MeshLineMaterial(
			useMap: false,
			color: new THREE.Color( options.color ),
			opacity: options.opacity,
			transparent: true,
			resolution: Stage3d.resolution,
			sizeAttenuation: false,
			lineWidth: options.width,
			blending: THREE.AdditiveBlending,
			near: Stage3d.camera.near,
			far: Stage3d.camera.far,
			depthTest:false,
			depthWrite:false
		)
		super(line.geometry,material)
		return

	@FromTo:(p1,p2,options={})->
		points = new Float32Array(6)
		points[0] = p1.x
		points[1] = p1.y
		points[2] = p1.z
		points[3] = p2.x
		points[4] = p2.y
		points[5] = p2.z
		return new Line(points,options)

	@FromPoints:(points,options={})->
		a = new Float32Array(points.length*3)
		for i in [0...points.length]
			a[i*3]	 = points[i].x
			a[i*3+1] = points[i].y
			a[i*3+2] = points[i].z
		return new Line(a,options)

module.exports = Line

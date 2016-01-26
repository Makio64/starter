#
# Simple Mesh Line Wrapper + Line utility
# By David Ronai / Makio64 / makiopolis.com
#

require("THREE.MeshLine")

Stage3d = require("makio/core/Stage3d")
Stage = require("makio/core/Stage")

class Line extends THREE.Mesh

	constructor:(points, options={})->

		line = new THREE.MeshLine()
		line.setGeometry( points )

		options.color ?= Math.floor(Math.random()*0xFFFFFF)
		options.width ?= 10
		options.opacity ?= 1

		material = new THREE.MeshLineMaterial(
			time: 0,
			map: options.texture,
			color: new THREE.Color( options.color ),
			opacity: options.opacity,
			transparent: true,
			resolution: Stage3d.resolution,
			sizeAttenuation: false,
			lineWidth: options.width,
			# blending: THREE.MultiplyBlending,
			side:THREE.DoubleSide
			near: Stage3d.camera.near,
			far: Stage3d.camera.far,
			# depthTest:false,
			depthWrite:false,
			fog:true
		)

		super(line.geometry,material)
		Stage.onUpdate.add(@update)
		return

	update:(dt)=>
		@material.uniforms.time.value += dt/1000
		return

	@FromTo:(p1,p2,options={},step = 2)->
		points = new Float32Array(step*3)
		for i in [0...step] by 1
			percent = i / (step-1)
			k = i*3
			points[k+0] = p1.x * ( 1 - percent ) + p2.x * percent
			points[k+1] = p1.y * ( 1 - percent ) + p2.y * percent
			points[k+2] = p1.z * ( 1 - percent ) + p2.z * percent
		return new Line(points,options)

	@FromPoints:(points,options={})->
		a = new Float32Array(points.length*3)
		for i in [0...points.length]
			a[i*3]	 = points[i].x
			a[i*3+1] = points[i].y
			a[i*3+2] = points[i].z
		return new Line(a,options)

module.exports = Line

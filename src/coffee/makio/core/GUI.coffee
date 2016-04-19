#
# Get unique instance of Dat.GUI
# @author : David Ronai / @Makio64 / makiopolis.com
#

gui = require('dat')
GUI  = new gui.GUI()
GUI.domElement.parentNode.style.zIndex = 100

toogle = ()->
	# toogle also stats
	stats = document.querySelector('.statsjs')
	if GUI.domElement.parentNode.style.display == 'none'
		if stats then stats.style.display = 'block'
		GUI.domElement.parentNode.style.display = 'block'
	else
		if stats then stats.style.display = 'none'
		GUI.domElement.parentNode.style.display = 'none'
	return

# require('./Interactions').onKeyDown.add((e)->
#     # hide gui on touch g
# 	if e == 71
# 		toogle()
# )

# if(document.location.hostname != "localhost")
# 	toogle()

module.exports = GUI

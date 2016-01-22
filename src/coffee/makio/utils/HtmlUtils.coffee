#
# HtmlUtils
# By David Ronai / Makio64 / makiopolis.com
#

class HtmlUtils

	constructor:()->
		throw new Error('HtmlUtils cant be instanciate')

	# -------------------------------------------------------------- Meta Data

	@getMeta=(property, doc)=>
		doc ?= document
		metas = doc.getElementsByTagName("meta")
		for meta in metas
			if(meta.property == property)
				return meta.content
		return null

	@getAllMeta=(doc)=>
		doc ?= document
		result = {}
		metas = doc.getElementsByTagName("meta")
		for meta in metas
			result.property = meta.content
		return result

	@changeMeta=(property, value, doc)=>
		doc ?= document
		metas = doc.getElementsByTagName("meta")
		for meta in metas
			if(meta.property == property)
				meta.content = value
				return
		return

	@updateMetaFB=(title,description,url,image,doc)=>
		@changeMeta("og:title",title,doc)
		@changeMeta("og:description",description,doc)
		@changeMeta("og:url",url,doc)
		@changeMeta("og:image",image,doc)
		return

module.exports = HtmlUtils

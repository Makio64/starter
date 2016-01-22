#
# JsUtils
# By David Ronai / Makio64 / makiopolis.com
#

TYPES = {
	'undefined'        : 'undefined',
	'number'           : 'number',
	'boolean'          : 'boolean',
	'string'           : 'string',
	'[object Function]': 'function',
	'[object RegExp]'  : 'regexp',
	'[object Array]'   : 'array',
	'[object Date]'    : 'date',
	'[object Error]'   : 'error'
}

module.exports.TYPES = TYPES
module.exports.type=(o)->
	return TYPES[typeof o] || TYPES[Object.prototype.toString.call(o)] || if o then 'object' else 'null'

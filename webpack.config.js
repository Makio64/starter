var webpack = require("webpack");
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

var plugins = []
module.exports = {
    entry: __dirname+"/src/coffee/Preloader",
	output: {
		path: 'build/js/',
		filename: 'bundle.js',
		chunkFilename: "[id].[chunkhash].bundle.js",
		publicPath: './js/'
	},
    module: {
        loaders: [
			{ test: /\.(glsl|vs|fs)$/, loader: 'shader' },
			{ test: /\.coffee$/, loader: 'coffee' },
			{ test: /\.jade$/, loader: 'jade-html' },
			{ test: /\.json$/, loader: 'json' },
			{ test: /\.jsx?$/, exclude:[/node_modules|vendors/], loader:'script' }
        ]
    },
	resolve: {
		extensions:['','.coffee','.glsl','.fs','.vs','.json','.js','.jade'],
		root:[
			__dirname+'/src/coffee',
			__dirname+'/src/jade',
			__dirname+'/src/glsl',
			__dirname+'/static/data/',
			__dirname+'/static/vendors/'
		],
		alias: {
			PIXI: 		__dirname+'/static/vendors/'+"pixi.js",
			THREE: 		__dirname+'/static/vendors/'+"three.js",
			WAGNER: 	__dirname+'/static/vendors/'+"wagner.js",
			dat: 		__dirname+'/static/vendors/'+"dat.gui.js",
			page: 		__dirname+'/static/vendors/'+"page.js",
			isMobile: 	__dirname+'/static/vendors/'+"isMobile.js",
			TweenMax: 	__dirname+'/static/vendors/'+"TweenMax.js",
			TweenLite: 	__dirname+'/static/vendors/'+"TweenLite.js",
		}
	},
	devServer: {
		proxy: {"*": {target:"/static/"} }
	},
	glsl: { chunkPath: __dirname+'/src/glsl/chunks' },
	plugins:[
		new webpack.ProvidePlugin({
			PIXI: "PIXI",
			THREE: "THREE",
			WAGNER: "WAGNER",
			TweenMax: "TweenMax",
			TweenLite: "TweenLite",
			dat: "dat",
			page: "page",
			isMobile: "isMobile"
		}),
		new BrowserSyncPlugin({
			host: 'localhost',
			port: 9000,
			server: { baseDir: ['build','static','src'] },
			open: true,
			files:['build/**/*','static/**/*']
		}),
		new webpack.optimize.CommonsChunkPlugin({children: true, async: true})
	]
};

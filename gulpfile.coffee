gulp       = require 'gulp'
browserify = require 'browserify'
transform  = require 'vinyl-transform'
source     = require 'vinyl-source-stream'
stylus     = require 'gulp-stylus'
rename     = require 'gulp-rename'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
webserver  = require 'gulp-webserver'
livereload = require 'gulp-livereload'
clean      = require 'gulp-clean'

browserified = transform (filename) ->
  browserify(filename).bundle()

# Our JS
gulp.task 'app_js', ->
  browserify [__dirname + '/lib/javascripts/index.cjsx']
    .bundle()
      .on 'error', (err) ->
        console.log err.message # should replace with gulp-util?
        @emit 'end'
    .pipe source 'application.js'
    .pipe gulp.dest './public/assets/javascripts'
    .pipe livereload()

# Vendor JS
jsDepNames = [
  "jquery/dist/jquery.js"
  "underscore/underscore.js"
]
jsDepPaths = ("./bower_components/#{depName}" for depName in jsDepNames)
gulp.task 'vendor_js', ->
  gulp.src jsDepPaths
    .pipe concat 'dependencies.js'
    .pipe gulp.dest './public/assets/javascripts'
    .pipe livereload()

# Styles
gulp.task 'app_styles', ->
  gulp.src './lib/styles/index.styl'
    .pipe plumber()
    .pipe stylus()
    .pipe rename 'application.css'
    .pipe gulp.dest './public/assets/styles'
    .pipe livereload()

gulp.task 'watch', ->
  gulp.watch './lib/javascripts/**/*', ['app_js']
  gulp.watch './lib/styles/*.styl', ['app_styles']

gulp.task 'webserver', ->
  gulp.src 'public'
    .pipe webserver(
      fallback:   'index.html' # gulp-webserver needs this for html5
      livereload: true
      open:       true
      directoryListing:
        enable: true
        path:   'public'
      )

gulp.task 'clean_js', ->
  gulp.src "./public/assets/javascripts/*.js", read: false
    .pipe plumber()
    .pipe clean()

gulp.task 'default', ['app_js', 'vendor_js', 'app_styles']
gulp.task 'serve', ['webserver', 'watch']
gulp       = require 'gulp'
browserify = require 'browserify'
source     = require 'vinyl-source-stream'
stylus     = require 'gulp-stylus'
rename     = require 'gulp-rename'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
webserver  = require 'gulp-webserver'
livereload = require 'gulp-livereload'
clean      = require 'gulp-clean'


jsDepPaths = [
  "./bower_components/jquery/dist/jquery.js"
  "./bower_components/underscore/underscore.js"
  "./bower_components/moment/moment.js"
]
gulp.task 'vendor_js', ->
  gulp.src jsDepPaths
    .pipe concat 'dependencies.js'
    .pipe gulp.dest './public/assets/javascripts'
    .pipe livereload()

#
# TODO Create separate browserify bundles to get react-canvas and react-data-viz out of app.js
#
gulp.task 'example_js', ->
  browserify [__dirname + '/example/index.cjsx']
    .bundle()
      .on 'error', (err) ->
        console.log err.message
        @emit 'end'
      .pipe source "application.js"
      .pipe gulp.dest './public/assets/javascripts'
      .pipe livereload()

# Styles
gulp.task 'app_styles', ->
  gulp.src './example/styles/index.styl'
    .pipe plumber()
    .pipe stylus()
    .pipe rename 'application.css'
    .pipe gulp.dest './public/assets/styles'
    .pipe livereload()

gulp.task 'watch', ->
  gulp.watch './lib/**/*', ['example_js']
  gulp.watch './example/**/*', ['example_js']
  gulp.watch './example/styles/*.styl', ['app_styles']

gulp.task 'webserver', ->
  gulp.src 'public'
    .pipe webserver(
      fallback:   'index.html' # gulp-webserver needs this for html5
      livereload: true
      directoryListing:
        enable: true
        path:   'public'
      )

gulp.task 'clean_examples', ->
  gulp.src "./public/assets/javascripts/application..js", read: false
    .pipe plumber()
    .pipe clean()

gulp.task 'default', ['example_js', 'vendor_js', 'app_styles']
gulp.task 'serve', ['webserver', 'watch']
gulp.task 'clean', ['clean_examples']

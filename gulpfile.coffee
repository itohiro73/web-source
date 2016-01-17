g = require 'gulp'
gulpif = require 'gulp-if'
browserSync = require 'browser-sync'
$ = require('gulp-load-plugins')()
path = require 'path'
rimraf = require 'rimraf'
zip = require 'gulp-zip'
debug = require 'gulp-debug'

handleError = (errors) ->
  console.log "Error!", errors.message

g.task 'clean-site', (cb)-> rimraf 'site', cb 
g.task 'clean-dist', (cb)-> rimraf 'dist', cb 
g.task 'clean', ["clean-site", "clean-dist"]
jadeTask = (lang) ->
  locales = require "./locale/#{lang}.json"

  g.src 'view/**/*.jade'
  .pipe $.jade {
    locals: locales
    pretty: true
  }
  .on('error', handleError)
  .pipe gulpif("#{lang}"=="en", g.dest("site"), g.dest("site/#{lang}/"))

  delete(require.cache[path.resolve("locale/#{lang}.json")])

g.task 'jade:ja', ['clean'], -> jadeTask("ja")
g.task 'jade:en', ['clean'], -> jadeTask("en")
g.task 'jade', ["jade:ja", "jade:en"]

g.task 'server', ['jade'], ->
  browserSync.init
    server:
      baseDir: "site"

  g.watch('view/**/*.jade', ['jade'])
  g.watch('locale/*.json', ['jade'])

g.task 'archive', ->
  g.src(['**/*'], {cwd: __dirname + "/site"})
  .pipe debug {title: 'archive:'}
  .pipe zip 'site.zip'
  .pipe g.dest './dist'


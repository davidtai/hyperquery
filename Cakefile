exec = require('shortcake').exec.interactive
path = require 'path'

option '-b', '--browser',                                                'run tests in browser'
option '-g', '--grep [filter]',                                          'test filter'
option '-t', '--test [file]',                                            'test to run'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcm -o .test test/'

task 'test', 'run tests', (options) ->
  test = options.test ? '.test'
  if options.grep?
    grep = "--grep #{options.grep}"
  else
    grep = ''

  if options.browser
    options._proc.kill() if options._proc?
    options._proc = exec "./node_modules/.bin/mocha-http
                         --timeout 5000
                         test"
  else
    exec "NODE_ENV=test ./node_modules/.bin/mocha
        --colors
        --reporter spec
        --timeout 5000
        --compilers coffee:coffee-script/register
        --require postmortem/register
        --require test/_helper
        #{grep}
        #{test}"

task 'test:browser', 'run tests', (options) ->
  options.browser = true
  invoke 'test'

task 'watch', 'watch for changes and recompile project', ->
  exec 'node_modules/.bin/coffee -bcmw -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcmw -o .test test/'

task 'watch:browser', 'watch and re-run tests in browser on change', (options) ->
  options.browser = true
  invoke 'watch:test'

task 'watch:test', 'watch and re-run tests on change', (options) ->
  invoke 'build', ->
    invoke 'test', ->
      runningTests = false

      require('vigil').watch __dirname, (filename, stats) ->
        return if runningTests

        if /\.coffee$/.test filename
          if /^test/.test filename
            out = '.test/'
            options.test = ".test/#{path.basename filename.split '.', 1}.js"
          else if /^src/.test filename
            out = (path.dirname filename).replace /^src/, 'lib'
            options.test = '.test'
          else
            console.log 'wut'
            return

          runningTests = true
          exec "node_modules/.bin/coffee -bcm -o #{out} #{filename}", ->
            console.log "#{(new Date).toLocaleTimeString()} - compiled #{filename}"
            invoke 'test', ->
              runningTests = false

task 'watch', 'watch for changes and recompile project', ->
  exec 'node_modules/.bin/coffee -bcmw -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcmw -o .test test/'

task 'example', 'Run example', ->
  exec [
    'cake build'
    'node example/serve.js'
  ]

task 'publish', 'Publish project', ->
  exec [
    'cake build'
    'git push'
    'npm publish'
  ]

exec = require('executive').interactive

task 'build', 'compile src/*.coffee to lib/*.js', ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcm -o .test test/'

task 'watch', 'watch for changes and recompile project', ->
  exec 'node_modules/.bin/coffee -bcmw -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcmw -o .test test/'

task 'test', 'Run tests', ->
  exec [
    'cake build'
    'NODE_ENV=test
    node_modules/.bin/mocha
    --colors
    --reporter spec
    --timeout 60000
    --compilers coffee:coffee-script/register
    --require postmortem/register
    .test'
    ]

task 'test-browser', 'Run tests in browser', ->
  exec 'node_modules/.bin/mocha-http test'

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

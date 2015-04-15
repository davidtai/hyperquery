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
    --compilers coffee:coffee-script/register
    --reporter spec
    --colors
    --timeout 60000
    --require test/_helper.js
    .test'
    ]

task 'publish', 'Publish project', ->
  exec [
    'cake build'
    'git push'
    'npm publish'
  ]
